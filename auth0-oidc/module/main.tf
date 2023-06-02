terraform {
  required_providers {
    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "~>3.0"
    }

    auth0 = {
      source  = "registry.terraform.io/auth0/auth0"
      version = "~>0.32"
    }
  }
}

data "aws_region" "current" {}
data "auth0_tenant" "current" {}

locals {
  app_name_prefix = var.app_name_prefix != null ? var.app_name_prefix : ""
}

resource "random_pet" "client_name" {
  prefix = local.app_name_prefix
}

resource "auth0_client" "client" {
  name                = random_pet.client_name.id
  description         = "OIDC Client suitable for full-stack web applications"
  app_type            = "regular_web"
  is_first_party      = true
  callbacks           = ["${var.root_url}${var.callback_path}"]
  allowed_logout_urls = [
    var.root_url, "${var.root_url}${var.logout_redirect_path}"
  ]
  jwt_configuration {
    alg = "RS256"
  }
}

resource "aws_ssm_parameter" "client_secret" {
  name        = "/auth0_oidc/${auth0_client.client.name}/client-secret"
  description = "The auth0 client secret"
  type        = "SecureString"
  value       = auth0_client.client.client_secret
}
