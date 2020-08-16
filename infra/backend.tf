terraform {
  backend "s3" {
    bucket = "akuma5157tfstate"
    key    = "ecomm-eks-mongo.terraform.tfstate"
    region = "us-east-1"
  }
}