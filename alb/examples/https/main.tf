terraform {
  required_version = ">=1.2.0, <2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}

provider "aws" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "alb" {
  source          = "../../module"
  name            = "example-https"
  subnets_ids     = data.aws_subnets.default.ids
  vpc_id          = data.aws_vpc.default.id
  enable_https    = true
  certificate_arn = module.alb_certificate.certificate_arn
}

module "alb_certificate" {
  source             = "../../../alb-certificate/module"
  alb_arn            = module.alb.arn
  domain_name_prefix = "demo-https"
  route53_zone_name  = "novocloudlab.com"
}

module "alternate_alb_certificate" {
  source             = "../../../alb-certificate/module"
  alb_arn            = module.alb.arn
  domain_name_prefix = "demo-alt"
  route53_zone_name  = "novocloudlab.com"
  attach_to_alb      = true
  alb_listener_arn   = module.alb.http_listener_arn
}

output "alb_arn" {
  value = module.alb.arn
}

output "alb_endpoint" {
  value = [
    "https://${module.alb_certificate.domain_name}",
    "https://${module.alternate_alb_certificate.domain_name}",
  ]
}
