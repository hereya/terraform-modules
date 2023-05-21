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
  source       = "../../module"
  name         = "example"
  subnets_ids  = data.aws_subnets.default.ids
  vpc_id       = data.aws_vpc.default.id
  enable_https = false
}

output "alb_arn" {
  value = module.alb.arn
}

output "alb_endpoint" {
  value = "http://${module.alb.dns_name}"
}
