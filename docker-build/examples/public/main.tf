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

variable "codecommit_username" {}
variable "codecommit_password_key" {}
variable "dockerhub_username" {}
variable "dockerhub_password" {}

module "docker_build" {
  source    = "../../module"
  providers = {
    aws.us-east-1 = aws.us-east-1
  }
  source_dir              = "${path.module}/my-app"
  is_public_image         = true
  image_tags              = ["latest", "v1.0.0"]
  image_name              = "my-awesome-app"
  force_delete_repository = true
  codecommit_username     = var.codecommit_username
  codecommit_password_key = var.codecommit_password_key
  dockerhub_username      = var.dockerhub_username
  dockerhub_password      = var.dockerhub_password
}

output "docker_images" {
  value = module.docker_build.images
}
