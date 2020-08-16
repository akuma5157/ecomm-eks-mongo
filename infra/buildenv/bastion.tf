resource "aws_security_group" "bastion" {
  name        = "${var.name}-bastion"
  description = "BuildEnv"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = concat(var.bastion_sec_grp_allow_ips, ["${chomp(data.http.controller-ip.body)}/32"])
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = concat(var.bastion_sec_grp_allow_ips, ["${chomp(data.http.controller-ip.body)}/32"])
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Environment = var.env
    Name = "${var.name}-Bastion"
  }
}
//
//resource "aws_instance" "bastion" {
//  ami = var.bastion_ami_id
//  instance_type = var.bastion_instance_type
//  iam_instance_profile = aws_iam_instance_profile.cicd-profile.name
//  vpc_security_group_ids = [aws_security_group.bastion.id]
//  subnet_id = var.bastion_subnet_id
//  key_name = var.bastion_key
//  associate_public_ip_address = true
//  tags = {
//    Name = "${var.name}-bastion"
//    Environment = var.env
//  }
//}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  name = "bastion"

  # Launch configuration
  lc_name = "bastion-lc"

  image_id        = var.bastion_ami_id
  key_name        = var.bastion_key
  instance_type   = var.bastion_instance_type
  security_groups = [aws_security_group.bastion.id, var.eks_cluster_sec_grp]
  iam_instance_profile = aws_iam_instance_profile.cicd-profile.name
  associate_public_ip_address = true
  recreate_asg_when_lc_changes = true

  # Auto scaling group
  asg_name                  = "bastion-asg"
  vpc_zone_identifier       = var.bastion_subnet_ids
  health_check_type         = "EC2"
  min_size                  = var.bastion_asg_min_size
  max_size                  = var.bastion_asg_max_size
  desired_capacity          = var.bastion_asg_min_size
  wait_for_capacity_timeout = 0

  tags_as_map = {
    Environment = var.env
  }
}