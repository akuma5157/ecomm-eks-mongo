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

variable "INSTANCE_TYPE" {
  type = string
  default = "t2.medium"
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

variable "PUB_SEC_GRP_CIDR_LIST" {
  type = list
  default = ["0.0.0.0/0"]
}

variable "EKS_INSTANCE_TYPE" {
  default = "t2.medium"
}

variable "ELK_INSTANCE_TYPE" {
  default = "t2.large"
}

variable "ASG_MIN_SIZE" {
  description = "Min nodes the cluster will have."
  default     = "2"
}

variable "ASG_MAX_SIZE" {
  description = "Max nodes the cluster will autoscale to."
  default     = "3"
}

variable "KAFKA_BROKERS_COUNT" {
  type = number
  default = 0
}

variable "JENKINS_ADMIN_PASSWD" {
  type = string
  default = "CAPGadmin1"
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
