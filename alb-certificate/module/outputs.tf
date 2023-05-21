output "certificate_arn" {
  description = "ARN of the certificate"
  value       = module.acm.acm_certificate_arn
}

output "domain_name" {
  value = "${var.domain_name_prefix}.${var.route53_zone_name}"
}
