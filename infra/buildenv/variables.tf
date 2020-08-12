variable "AWS_REGION" {
  type = string
  default = "us-east-1"
}

variable "KEY" {
  type = string
  default = "test-poc"
}

variable "env" {
  type = string
  default = "Collections"
}

variable "NAME" {
  type = string
  default = "try"
}

variable "AMI_ID" {
  type = string
  default = "ami-026c8acd92718196b"
}

variable "INSTANCE_TYPE" {
  default = "t2.medium"
}

variable "SUBNET_ID" {
  default = "subnet-06c1ac29"
}

variable "VPC_ID" {
  default = "vpc-aa6c67d2"
}

variable "VPC_CIDR" {
  default = "172.31.0.0/16"
}

variable "PUB_SEC_GRP_CIDR_LIST" {
  type = list
  default = ["0.0.0.0/0"]
}

variable "JENKINS_ADMIN_PASSWD" {
  type = string
  default = "CAPGadmin1"
}
