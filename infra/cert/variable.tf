variable "domain_name" {
  type        = string
  description = "Primary certificate domain name"
}

variable "hosted_zone_id" {
  type        = string
  description = "Route 53 Zone ID for DNS validation records"
}
