terraform {
  required_providers {
    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "~> 3.4"
    }

    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "aws_region" "current" {}

resource "random_pet" "client_name" {}

resource "aws_cognito_user_pool_client" "client" {
  name = random_pet.client_name.id

  user_pool_id = var.cognito_user_pool_id

  generate_secret = true
  callback_urls   = ["${var.app_base_url}${var.callback_path}"]
  logout_urls     = [
    "${var.app_base_url}${var.logout_redirect_path}"
  ]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  supported_identity_providers         = ["COGNITO"]
}

resource "aws_ssm_parameter" "client_secret" {
  name        = "/cognito_app/${random_pet.client_name.id}/client_secret"
  description = "Client secret for ${random_pet.client_name.id}"
  type        = "SecureString"
  value       = aws_cognito_user_pool_client.client.client_secret
}

