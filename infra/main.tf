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

module "network" {
  source = "./network"
  aws_region = var.aws_region
  env = var.env
  name = var.name
  public_subnet_bastion_cidr = var.public_subnet_bastion_cidr
  private_subnet_build_cidr = var.private_subnet_build_cidr
  private_subnet_app_cidr = var.private_subnet_app_cidr
  private_subnet_db_cidr = var.private_subnet_db_cidr
}
//
//module "buildenv" {
//  source = "./buildenv"
//  AWS_REGION = var.AWS_REGION
//  env = var.env
//  name = var.name
//  AMI_ID = data.aws_ami.ubuntu.image_id
//  INSTANCE_TYPE = "t2.medium"
//  KEY = module.network.key-name
//  SUBNET_ID = module.network.public_subnets
//  VPC_ID = module.network.vpc_id
//  VPC_CIDR = module.network.vpc_cidr
//  PUB_SEC_GRP_CIDR_LIST = var.PUB_SEC_GRP_CIDR_LIST
//  JENKINS_ADMIN_PASSWD = var.JENKINS_ADMIN_PASSWD
//}
//
module "runenv" {
  source = "./eks_cluster"
  aws_region = var.aws_region
  env = var.env
  name = var.name
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
//  map_roles = concat(var.map_roles, [
//                {
//                  role_arn = module.buildenv.cicd_role.arn   // "arn:aws:iam::123456789012:role/collections-terraform-ec2"
//                  username = module.buildenv.cicd_role.name  // "collections-terraform-ec2"
//                  group    = "system:masters"
//                }
//              ])
}

//resource "null_resource" "jenkins_config" {
//  depends_on = [
//    module.eks_cluster.kubectl_config,
//    module.eks_cluster.kafka_zookeeper,
//    module.eks_cluster.mariadb,
//    module.network.key-name,
//    module.buildenv.nexus,
//    module.buildenv.jenkins
//  ]
//
//  triggers = {
//    kubectl = module.eks_cluster.kubectl_config
//    key-name = module.network.key-name
//    zookeeper = module.eks_cluster.kafka_zookeeper.private_ip
//    mariadb = module.eks_cluster.mariadb.private_ip
//    jenkins = module.buildenv.jenkins.private_ip
//    nexus = module.buildenv.nexus.private_ip
//    config_file = file("./jenkins_config.tpl.sh")
//  }
//
//  provisioner "local-exec" {
//    working_dir = path.module
//    command = templatefile("./jenkins_config.tpl.sh",
//              {
//                key_file    = module.network.key-name
//                jenkins_ip  = module.buildenv.jenkins.public_ip
//                nexus_ip    = module.buildenv.nexus.private_ip
//                mariadb_ip  = module.eks_cluster.mariadb.private_ip
//                kafka_ip    = module.eks_cluster.kafka_zookeeper.private_ip
//                sonar_ip    = module.buildenv.sonarqube.private_ip
//                kubeconfig  = "kubeconfig_${var.name}-EKS"
//              }
//    )
//    interpreter = [
//      "/bin/bash",
//      "-c"]
//  }
//}
//
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
//                    "curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator ; ",
//                    "chmod +x ./aws-iam-authenticator ; ",
//                    "sudo mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator ; '",
//              ])
//  }
//}
