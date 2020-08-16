module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  version      = "12.2.0"
  cluster_version = "1.17"
  cluster_name = "${var.name}-EKS"
  subnets      = concat(var.private_subnets, var.public_subnets)
  tags         = {
    Name = "${var.name}-EKS"
    Environment = var.env
  }
  vpc_id       = var.vpc_id
  cluster_create_timeout = "30m"
  cluster_delete_timeout = "30m"
  cluster_endpoint_private_access = true

  worker_groups = list(
    {
      asg_desired_capacity = var.build_asg_min_size,
      asg_max_size = var.build_asg_max_size,
      asg_min_size = var.build_asg_min_size,
      instance_type = var.build_asg_instance_type,
      kubelet_extra_args = "--node-labels=tier=build"
      name = "build",
      autoscaling_enabled = true,
      protect_from_scale_in = false,
      subnets = slice(var.private_subnets, 0, 3)
    },
    {
      asg_desired_capacity = var.app_asg_min_size,
      asg_max_size = var.app_asg_max_size,
      asg_min_size = var.app_asg_min_size,
      instance_type = var.app_asg_instance_type,
      kubelet_extra_args = "--node-labels=tier=app --register-with-taints=tier=app_only:NoSchedule"
      name = "app",
      autoscaling_enabled = true,
      protect_from_scale_in = false,
      subnets = slice(var.private_subnets, 3, 6)
    },
    {
      asg_desired_capacity = var.db_asg_min_size,
      asg_max_size = var.db_asg_max_size,
      asg_min_size = var.db_asg_min_size,
      instance_type = var.db_asg_instance_type,
      kubelet_extra_args = "--node-labels=tier=data --register-with-taints=tier=data_only:NoSchedule"
      name = "db",
      autoscaling_enabled = true,
      protect_from_scale_in = false,
      subnets = slice(var.private_subnets, 6, 9)
    }
  )
  map_users          = var.map_users
  map_roles          = var.map_roles
}
