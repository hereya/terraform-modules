variable "domain_name_prefix" {
  description = "The domain name prefix to use for the domain"
  type        = string
}

variable "route53_zone_name" {
  description = "The name of the Route53 zone for the domain"
  type        = string
}

variable "alb_arn" {
  description = "The ARN of the ALB to associate the certificate with"
  type        = string
}


variable "create_www_alias" {
  description = "Whether to create a www alias for the domain"
  type        = bool
  default     = false
}

variable "alb_listener_arn" {
  description = "The ARN of the ALB listener to associate the certificate with"
  type        = string
  default     = null
}

variable "attach_to_alb" {
  description = "Whether to attach the certificate to the ALB"
  type        = bool
  default     = false
}
