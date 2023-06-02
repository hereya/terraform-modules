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

provider "random" {}
provider "auth0" {}


module "auth0_oidc" {
  source              = "../../module"
  app_name_prefix     = "test"
  auth0_custom_domain = var.auth0_custom_domain
  root_url            = "http://localhost:3000"
}
