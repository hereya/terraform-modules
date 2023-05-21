variable "name" {
  type        = string
  description = "Name to be used on all the resources as identifier"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to be used for the ALB"
}

variable "subnets_ids" {
  type        = list(string)
  description = "List of subnets IDs to be used for the ALB"
}

variable "enable_https" {
  type        = bool
  description = "Enable HTTPS"
  default     = true
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the certificate to be used for the ALB"
  default     = null
}
