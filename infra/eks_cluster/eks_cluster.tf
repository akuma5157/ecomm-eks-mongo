module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  version      = "12.2.0"
  cluster_version = "1.17"
  cluster_name = "${var.name}-EKS"
  subnets      = concat(var.public_subnets_bastion, var.private_subnets_build, var.private_subnets_app, var.private_subnets_db)
  tags         = {
    Name = "${var.name}-EKS"
    Environment = var.env
  }
  vpc_id       = var.vpc_id
  cluster_create_timeout = "30m"
  cluster_delete_timeout = "30m"

  worker_groups = list(
    {
      asg_desired_capacity = var.build_asg_min_size,
      asg_max_size = var.build_asg_max_size,
      asg_min_size = var.build_asg_min_size,
      instance_type = var.build_asg_instance_type,
      name = "build",
      autoscaling_enabled = true,
      protect_from_scale_in = false,
      subnets = var.private_subnets_build,
    },
    {
      asg_desired_capacity = var.app_asg_min_size,
      asg_max_size = var.app_asg_max_size,
      asg_min_size = var.app_asg_min_size,
      instance_type = var.app_asg_instance_type,
      name = "app",
      autoscaling_enabled = true,
      protect_from_scale_in = false,
      subnets = var.private_subnets_app,
    },
    {
      asg_desired_capacity = var.db_asg_min_size,
      asg_max_size = var.db_asg_max_size,
      asg_min_size = var.db_asg_min_size,
      instance_type = var.db_asg_instance_type,
      name = "db",
      autoscaling_enabled = true,
      protect_from_scale_in = false,
      subnets = var.private_subnets_db,
    }
  )
  map_users          = var.map_users
  map_roles          = var.map_roles
}
provider "kubernetes" {
  config_path = "kubeconfig_${var.name}-EKS"
}

resource "kubernetes_namespace" "build" {
  metadata {
    labels = {
      Name = "build"
    }
    name = "build"
  }
}
resource "kubernetes_namespace" "app" {
  metadata {
    labels = {
      Name = "app"
    }
    name = "app"
  }
}
resource "kubernetes_namespace" "db" {
  metadata {
    labels = {
      Name = "db"
    }
    name = "db"
  }
}
