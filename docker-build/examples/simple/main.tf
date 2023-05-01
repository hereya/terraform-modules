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
provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

module "docker_build" {
  source        = "../../module"
  source_dir    = "${path.module}/my-app"
  source_bucket = "dream-poc-hereya-dev"
  providers     = {
    aws.us-east-1 = aws.us-east-1
  }
}

output "docker_images" {
  value = module.docker_build.images
}
