module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "2.47.0"
  name = "${var.name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = concat(var.private_subnet_build_cidr, var.private_subnet_app_cidr, var.private_subnet_db_cidr)
  public_subnets  = var.public_subnet_bastion_cidr

  enable_nat_gateway  = true
  one_nat_gateway_per_az = true
  enable_vpn_gateway  = false
  enable_dhcp_options = false

  tags = {
    Environment = var.env
    Name    = "${var.name}-vpc"
    "kubernetes.io/cluster/${var.name}-EKS" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

data "aws_subnet_ids" "bastion" {
  vpc_id = module.vpc.vpc_id
  filter {
    name   = "cidr:Name"
    values = var.public_subnet_bastion_cidr
  }
}

data "aws_subnet_ids" "build" {
  vpc_id = module.vpc.vpc_id
  filter {
    name   = "cidr"
    values = var.private_subnet_build_cidr
  }
}

data "aws_subnet_ids" "app" {
  vpc_id = module.vpc.vpc_id
  filter {
    name   = "cidr"
    values = var.private_subnet_app_cidr
  }
}

data "aws_subnet_ids" "db" {
  vpc_id = module.vpc.vpc_id
  filter {
    name   = "cidr"
    values = var.private_subnet_db_cidr
  }
}

provider "tls" {}

resource "tls_private_key" "sshkey" {
  algorithm = "RSA"
  rsa_bits  = "2048"

  provisioner "local-exec" {
    command     = "echo \"${tls_private_key.sshkey.private_key_pem}\" > ${path.cwd}/${var.name}_key"
    interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    command     = "echo \"${tls_private_key.sshkey.public_key_openssh}\" > ${path.cwd}/${var.name}_key.pub"
    interpreter = ["/bin/sh", "-c"]
  }

  provisioner "local-exec" {
    command     = "chmod 600 ${var.name}_key"
    interpreter = ["/bin/sh", "-c"]
  }
}

resource "aws_key_pair" "sshkey" {
  key_name   = "${var.name}_key"
  public_key = tls_private_key.sshkey.public_key_openssh
}


