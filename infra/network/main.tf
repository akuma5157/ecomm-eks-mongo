provider "aws" {
  region = var.aws_region  # "us-east-1"
}
data "aws_availability_zones" "available" {
  state = "available"
}
