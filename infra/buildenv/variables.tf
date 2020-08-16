variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "env" {
  type = string
  default = "Collections"
}

variable "name" {
  type = string
  default = "try"
}

variable "vpc_id" {
  default = "vpc-aa6c67d2"
}

variable "vpc_cidr" {
  default = "172.31.0.0/16"
}

variable "jenkins_key" {
  type = string
  default = "test-poc"
}

variable "jenkins_ami_id" {
  type = string
  default = "ami-026c8acd92718196b"
}

variable "jenkins_subnet_id" {
  default = "subnet-06c1ac29"
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

variable "bastion_key" {
  type = string
  default = "test-poc"
}

variable "bastion_ami_id" {
  type = string
  default = "ami-026c8acd92718196b"
}

variable "bastion_subnet_ids" {
  type = list(string)
  default = [""]
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

variable "eks_cluster_sec_grp" {}
