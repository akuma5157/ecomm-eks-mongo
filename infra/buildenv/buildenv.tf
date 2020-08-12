resource "aws_security_group" "build_env" {
  name        = "${var.NAME}-build_env"
  description = "BuildEnv"
  vpc_id      = var.VPC_ID
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.VPC_CIDR]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.PUB_SEC_GRP_CIDR_LIST
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.PUB_SEC_GRP_CIDR_LIST
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Environment = var.env
    Name = "${var.NAME}-BuildEnv"
  }
}

resource "aws_instance" "nexus" {
  ami           = var.AMI_ID
  instance_type = var.INSTANCE_TYPE  # "t2.micro"
  vpc_security_group_ids = [aws_security_group.build_env.id]
  subnet_id = var.SUBNET_ID   # "subnet-f9f87da4"
  key_name = var.KEY  # "LaaS_COS2"
  associate_public_ip_address = true
  root_block_device {
      volume_size = 20
      delete_on_termination = true
  }
  tags = {
    Environment = var.env
    Name = "${var.NAME}-nexus"
  }
  user_data = file("${path.module}/scripts/nexus-script.sh")
}

resource "aws_ecr_repository" "ecr" {
  name = "${var.NAME}-ecr"
}

resource "aws_instance" "jenkins" {
  ami           = var.AMI_ID
  instance_type = var.INSTANCE_TYPE
  # the VPC subnet
  subnet_id = var.SUBNET_ID

  # the security group
  vpc_security_group_ids = [aws_security_group.build_env.id]

  # the public SSH key
  key_name = var.KEY
  root_block_device {
      volume_size = 20
      delete_on_termination = true
  }
  iam_instance_profile = aws_iam_instance_profile.cicd-profile.name
  associate_public_ip_address = true
  tags = {
    Environment = var.env
    Name = "${var.NAME}-jenkins"
  }
  user_data = templatefile("${path.module}/scripts/jenkins-script.tpl.sh",
                {
                  nexus_ip = aws_instance.nexus.private_ip
                  ecr_url  = split("/", aws_ecr_repository.ecr.repository_url)[0]
                  aws_region = var.AWS_REGION
                  admin_passwd = var.JENKINS_ADMIN_PASSWD
                }
              )
}

resource "aws_instance" "sonarqube" {
  ami           = var.AMI_ID
  instance_type = var.INSTANCE_TYPE
  vpc_security_group_ids = [aws_security_group.build_env.id]
  subnet_id = var.SUBNET_ID
  key_name = var.KEY
  associate_public_ip_address = true
  root_block_device {
      volume_size = 20
      delete_on_termination = true
  }
  tags = {
    Environment = var.env
    Name = "${var.NAME}-sonarqube"
  }
  user_data = file("${path.module}/scripts/sonarqube-script.sh")
}


