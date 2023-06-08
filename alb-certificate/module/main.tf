terraform {
  required_version = ">=1.2.0, <2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}


data "aws_route53_zone" "domain" {
  name         = var.route53_zone_name
  private_zone = var.is_private_domain
}

locals {
  domain_name = "${var.domain_name_prefix}.${var.route53_zone_name}"
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = local.domain_name
  zone_id     = data.aws_route53_zone.domain.zone_id

  subject_alternative_names = var.create_www_alias? [
    "www.${local.domain_name}"
  ] : []

  wait_for_validation = true

  tags = {
    Name = local.domain_name
  }
}

data "aws_lb" "alb" {
  arn = var.alb_arn
}

resource "aws_route53_record" "www" {
  for_each = var.create_www_alias ? toset([
    local.domain_name, "www.${local.domain_name}"
  ]) : toset([local.domain_name])
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = each.value
  type    = "A"

  alias {
    name                   = data.aws_lb.alb.dns_name
    zone_id                = data.aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_listener_certificate" "alb" {
  count           = var.attach_to_alb ? 1 : 0
  listener_arn    = var.alb_listener_arn
  certificate_arn = module.acm.acm_certificate_arn

  lifecycle {
    precondition {
      condition     = var.alb_listener_arn != null
      error_message = "ALB Listener ARN must be specified when attaching ACM certificate to ALB"
    }
  }
}
