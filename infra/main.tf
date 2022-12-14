provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = [
      "hvm"]
  }

  owners = [
    "099720109477"]
}

data "aws_caller_identity" "current" {}

module "network" {
  source = "./network"
  aws_region = var.aws_region
  env = var.env
  name = var.name
  vpc_cidr = var.vpc_cidr
  public_subnet_bastion_cidr = var.public_subnet_bastion_cidr
  private_subnet_build_cidr = var.private_subnet_build_cidr
  private_subnet_app_cidr = var.private_subnet_app_cidr
  private_subnet_db_cidr = var.private_subnet_db_cidr
}

module "buildenv" {
  source = "./buildenv"
  aws_region = var.aws_region
  env = var.env
  name = var.name
  vpc_id = module.network.vpc_id
  vpc_cidr = module.network.vpc_cidr
  bastion_ami_id = data.aws_ami.ubuntu.image_id
  bastion_instance_type = var.jenkins_instance_type
  bastion_key = module.network.key-name
  bastion_subnet_ids = module.network.public_subnets_bastion
  bastion_sec_grp_allow_ips = var.bastion_sec_grp_allow_ips
  bastion_asg_min_size = var.bastion_asg_min_size
  bastion_asg_max_size = var.bastion_asg_max_size
  jenkins_ami_id = data.aws_ami.ubuntu.image_id
  jenkins_instance_type = var.jenkins_instance_type
  jenkins_key = module.network.key-name
  jenkins_subnet_id = module.network.public_subnets[0]
  jenkins_sec_grp_allow_ips = var.jenkins_sec_grp_allow_ips
  jenkins_admin_username = var.jenkins_admin_username
  jenkins_admin_password = var.jenkins_admin_password
  eks_cluster_sec_grp = module.eks_cluster.eks_cluster_sec_grp
}

module "eks_cluster" {
  source = "./eks_cluster"
  aws_region = var.aws_region
  env = var.env
  name = var.name
  domain_name = module.domain.domain_name
  cert_arn = module.cert.arn
  build_asg_min_size = var.build_asg_min_size
  build_asg_max_size = var.build_asg_max_size
  build_asg_instance_type = var.build_asg_instance_type
  app_asg_min_size = var.app_asg_min_size
  app_asg_max_size = var.app_asg_max_size
  app_asg_instance_type = var.app_asg_instance_type
  db_asg_min_size = var.db_asg_min_size
  db_asg_max_size = var.db_asg_max_size
  db_asg_instance_type = var.db_asg_instance_type
  vpc_id = module.network.vpc_id
  private_subnets = module.network.private_subnets
  public_subnets = module.network.public_subnets
  private_subnets_app = module.network.private_subnets_app
  private_subnets_build = module.network.private_subnets_build
  private_subnets_db = module.network.private_subnets_db
  public_subnets_bastion = module.network.public_subnets_bastion
  map_users = concat(var.map_users, [
                {
                  userarn = data.aws_caller_identity.current.arn
                  username = data.aws_caller_identity.current.user_id
                  groups = ["system:masters"]
                }
              ])
  map_roles = concat(var.map_roles, [
                {
                  rolearn = module.buildenv.cicd_role.arn
                  username = module.buildenv.cicd_role.name
                  groups = ["system:masters"]
                }
              ])
}

data "aws_eks_cluster" "cluster" {
  name  = module.eks_cluster.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name  = module.eks_cluster.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
  }
}

module "k8s" {
  source = "./k8s"
  depends_on = [module.eks_cluster]
  vpc_id = module.network.vpc_id
  name = var.name
  aws_region = var.aws_region
  domain_name = module.domain.domain_name
  cert_arn = module.cert.arn
  eks_cluster_name = module.eks_cluster.cluster_name
  eks_oidc_url = module.eks_cluster.eks_oidc_url
  private_subnets = module.network.private_subnets
  public_subnets = module.network.public_subnets
}

module "domain" {
  source = "./domain"
  domain_name = var.route53_domain_name
}

module "cert" {
  source = "./cert"
  domain_name = module.domain.domain_name
  hosted_zone_id = module.domain.hosted_zone_id
}

//resource "null_resource" "bastion-config" {
//  depends_on = [
//    module.eks_cluster.kubectl_config,
//    module.eks_cluster.bastion
//  ]
//
//  triggers = {
//    kubeconfig = module.eks_cluster.kubectl_config
//  }
//
//  provisioner "local-exec" {
//    command = join(" ", [
//                  "sleep 30 ; ",
//                  "scp -i ${var.name}_key -o StrictHostKeyChecking=no",
//                    "${var.name}_key ubuntu@${module.eks_cluster.bastion.public_ip}:${var.name}_key ; ",
//                  "scp -i ${var.name}_key -o StrictHostKeyChecking=no ",
//                    "kubeconfig_${var.name}-EKS ubuntu@${module.eks_cluster.bastion.public_ip}:~/.kube/config ;",
//                  "ssh -i ${var.name}_key -o StrictHostKeyChecking=no ubuntu@${module.eks_cluster.bastion.public_ip}",
//                    "'chmod 600 ${var.name}_key ; ",
//                    "(mkdir /home/ubuntu/.kube) ; ",
//                    "chown ubuntu:ubuntu -R /home/ubuntu/.kube ; ",
//                    "curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl ; ",
//                    "chmod +x ./kubectl ; ",
//                    "sudo mv ./kubectl /usr/local/bin/kubectl ; ",
//                    "curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.7/2020-07-08/bin/linux/amd64/aws-iam-authenticator ; ",
//                    "chmod +x ./aws-iam-authenticator ; ",
//                    "sudo mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator ; '",
//              ])
//  }
//}
