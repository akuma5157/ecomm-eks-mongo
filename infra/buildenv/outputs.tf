output "security_group" {
  value = aws_security_group.jenkins
}

output "jenkins" {
  value = aws_instance.jenkins
}

output "cicd_role" {
  value = aws_iam_role.cicd-role
}

output "cicd_instance_profile" {
  value = aws_iam_instance_profile.cicd-profile.name
}
