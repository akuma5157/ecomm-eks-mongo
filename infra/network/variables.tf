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
  default = "test"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "private_subnet_build_cidr" {
  type = list(string)
  default = [""]
}

variable "private_subnet_app_cidr" {
  type = list(string)
  default = [""]
}

variable "private_subnet_db_cidr" {
  type = list(string)
  default = [""]
}

variable "public_subnet_bastion_cidr" {
  type = list(string)
  default = [""]
}