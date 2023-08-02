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

variable "image_tags" {
  type    = list(string)
  default = null
}
variable "codecommit_username" {}
variable "codecommit_password_key" {}
variable "dockerhub_username" {}
variable "dockerhub_password" {}

module "docker_build" {
  source     = "../../module"
  source_dir = "${path.module}/app"
  providers  = {
    aws.us-east-1 = aws.us-east-1
  }
  build_with_docker       = true
  is_public_image         = true
  image_name              = "docker-build-test"
  force_delete_repository = true
  image_tags              = var.image_tags
  codecommit_username     = var.codecommit_username
  codecommit_password_key = var.codecommit_password_key
  dockerhub_username      = var.dockerhub_username
  dockerhub_password      = var.dockerhub_password
}

output "docker_images" {
  value = module.docker_build.images
}