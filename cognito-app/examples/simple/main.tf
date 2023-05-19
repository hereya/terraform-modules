terraform {
  required_version = ">= 1.2.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {}

module "cognito_app" {
  source                   = "../../module"
  cognito_user_pool_domain = var.cognito_user_pool_domain
  cognito_user_pool_id     = var.cognito_user_pool_id
  app_base_url             = "http://localhost:8788"
}
