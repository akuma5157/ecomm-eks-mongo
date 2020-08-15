output "arn" {
  value = aws_acm_certificate.primary.arn
}

output "rout53_domain_name" {
  value = var.domain_name
}