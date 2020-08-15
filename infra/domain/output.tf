output "hosted_zone_name" {
  value = var.domain_name
}

output "hosted_zone_id" {
  value = aws_route53_zone.main.zone_id
}

output "domain_name" {
  value = var.domain_name
}
