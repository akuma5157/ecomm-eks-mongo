variable "aws_region" {
  type = string
  description = "AWS region."
  default = "us-east-1"
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
      rolearn = "arn:aws:iam::123456789012:role/test-terraform-ec2"
      username = "test-terraform-ec2"
      groups    = ["system:masters"]
    },
  ]
}

variable "name" {
  type = string
  default = "try"
}

variable "env" {
  type = string
  default = "test"
}

variable "private_subnets" {
  type = list(string)
  default = [""]
}

variable "public_subnets" {
  type = list(string)
  default = [""]
}

variable "private_subnets_build" {
  type = list(string)
  default = [""]
}

variable "private_subnets_app" {
  type = list(string)
  default = [""]
}

variable "private_subnets_db" {
  type = list(string)
  default = [""]
}

variable "public_subnets_bastion" {
  type = list(string)
  default = [""]
}

variable "vpc_id" {
  default = ""
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

variable "domain_name" {
  default = ""
}

variable "cert_arn" {
  type = string
  default = ""
}
