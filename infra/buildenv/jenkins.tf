resource "aws_security_group" "jenkins" {
  name        = "${var.name}-jenkins"
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
    cidr_blocks = concat(var.jenkins_sec_grp_allow_ips, ["${chomp(data.http.controller-ip.body)}/32"])
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = concat(var.jenkins_sec_grp_allow_ips, ["${chomp(data.http.controller-ip.body)}/32"])
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Environment = var.env
    Name = "${var.name}-Jenkins"
  }
}

resource "aws_instance" "jenkins" {
  ami           = var.jenkins_ami_id
  instance_type = var.jenkins_ami_id
  subnet_id = var.jenkins_subnet_id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  key_name = var.jenkins_key
  root_block_device {
      volume_size = 20
      delete_on_termination = true
  }
  iam_instance_profile = aws_iam_instance_profile.cicd-profile.name
  associate_public_ip_address = true
  tags = {
    Environment = var.env
    Name = "${var.name}-jenkins-master"
  }
}
resource "null_resource" "jenkins_config" {
  depends_on = [
    aws_instance.jenkins
  ]
  triggers = {
    instance = aws_instance.jenkins.public_dns
    playbook = file("${path.module}/jenkins-playbook.yml")
  }
  provisioner "local-exec" {
    working_dir = path.module
    command = "ansible-playbook -u ubuntu -i ${aws_instance.jenkins.public_dns}, jenkins-playbook.yml --private-key ${path.cwd}/${var.name}_key -e jenkins_admin_username='${var.jenkins_admin_username}' -e jenkins_admin_password='${var.jenkins_admin_password}'"
  }
}