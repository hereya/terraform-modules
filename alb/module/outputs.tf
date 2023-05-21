output "dns_name" {
  description = "The public dns name of the ALB"
  value       = aws_lb.this.dns_name
}

output "security_group_id" {
  description = "The security group id of the ALB"
  value       = aws_security_group.http.id
}

output "http_listener_arn" {
  description = "The ARN of the HTTP listener"
  value       = var.enable_https ? aws_lb_listener.https.0.arn : aws_lb_listener.http.0.arn
}

output "zone_id" {
  description = "The zone id of the ALB"
  value       = aws_lb.this.zone_id
}

output "arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.this.arn
}