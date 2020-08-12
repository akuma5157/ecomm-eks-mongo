output ecr {
  value = aws_ecr_repository.ecr
}
output "security_group" {
  value = aws_security_group.build_env
}
output "nexus" {
  value = aws_instance.nexus
}
output "jenkins" {
  value = aws_instance.jenkins
}
output "sonarqube" {
  value = aws_instance.sonarqube
}

output "cicd_role" {
  value = aws_iam_role.cicd-role
}

output "cicd_instance_profile" {
  value = aws_iam_instance_profile.cicd-profile.name
}
