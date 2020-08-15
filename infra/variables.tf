variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "env" {
  type = string
  default = "test"
}

variable "route53_domain_name" {
  type = string
  default = "ecomm-eks-mongo-akuma.com"
}

variable "name" {
  type = string
  default = "try"
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  default = [
    {
      userarn = "arn:aws:iam::123456789012:user/ajay"
      username = "ajay"
      groups    = ["system:masters"]
    }
  ]
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  default = [
    {
      rolearn = "arn:aws:iam::123456789012:role/collections-terraform-ec2"
      username = "collections-terraform-ec2"
      groups    = ["system:masters"]
    }
  ]
}

variable "bastion_instance_type" {
  default = "t2.micro"
}

variable "bastion_sec_grp_allow_ips" {
  type = list(string)
  default = ["127.0.0.1/32"]
}

variable "bastion_asg_min_size" {
  default = "1"
}

variable "bastion_asg_max_size" {
  default = "2"
}

variable "jenkins_instance_type" {
  default = "t2.micro"
}

variable "jenkins_sec_grp_allow_ips" {
  type = list(string)
  default = ["127.0.0.1/32"]
}

variable "jenkins_admin_username" {
  type = string
  default = "admin"
}

variable "jenkins_admin_password" {
  type = string
  default = "admin"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "private_subnet_build_cidr" {
  type = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "private_subnet_app_cidr" {
  type = list(string)
  default = ["10.0.16.0/20", "10.0.32.0/20", "10.0.48.0/20"]
}

variable "private_subnet_db_cidr" {
  type = list(string)
  default = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
}

variable "public_subnet_bastion_cidr" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}


variable "build_asg_min_size" {
  description = "min nodes the cluster will have."
  default     = "1"
}

variable "build_asg_max_size" {
  description = "max nodes the cluster will autoscale to."
  default     = "2"
}

variable "build_asg_instance_type" {
  default = "t2.micro"
}

variable "app_asg_min_size" {
  description = "min nodes the cluster will have."
  default     = "1"
}

variable "app_asg_max_size" {
  description = "max nodes the cluster will autoscale to."
  default     = "2"
}

variable "app_asg_instance_type" {
  default = "t2.micro"
}

variable "db_asg_min_size" {
  description = "min nodes the cluster will have."
  default     = "1"
}

variable "db_asg_max_size" {
  description = "max nodes the cluster will autoscale to."
  default     = "2"
}

variable "db_asg_instance_type" {
  default = "t2.micro"
}
