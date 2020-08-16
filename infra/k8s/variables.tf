variable "aws_region" {
  type = string
  description = "AWS region."
  default = "us-east-1"
}

variable "name" {
  default = "name"
}

variable "vpc_id" {
  default = ""
}
variable "private_subnets" {
  type = list(string)
  default = [""]
}
variable "public_subnets" {
  type = list(string)
  default = [""]
}
variable "eks_cluster_name" {
  type = string
  default = ""
}

variable "domain_name" {
  default = ""
}

variable "cert_arn" {
  type = string
  default = ""
}

variable "eks_oidc_url" {
  type = string
  default = ""
}
