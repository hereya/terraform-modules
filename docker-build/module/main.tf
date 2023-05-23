terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~>2.3"
    }
    aws = {
      source                = "registry.terraform.io/hashicorp/aws"
      version               = "~> 4.0"
      //noinspection HILUnresolvedReference
      configuration_aliases = [aws.us-east-1]
    }
    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "~> 3.4"
    }
  }
}

data "external" "last_commit" {
  program     = ["bash", "${abspath(path.module)}/get_last_commit.sh"]
  working_dir = var.source_dir
}

data "external" "current_branch" {
  program     = ["bash", "${abspath(path.module)}/get_current_branch.sh"]
  working_dir = var.source_dir
}

locals {
  image_name = var.image_name != null ? var.image_name : random_pet.generated_image_name.0.id
  image_tags = var.image_tags != null ? var.image_tags : [
    data.external.last_commit.result.hash, "latest"
  ]
  repository_url = var.is_public_image ? aws_ecrpublic_repository.public.0.repository_uri : aws_ecr_repository.private.0.repository_url
  ecr_url        = dirname(local.repository_url)

  pack_buildspec_file = templatefile("${path.module}/pack_buildspec.yml", {
    imageName     = local.image_name
    imageTags     = join(" ", [for tag in local.image_tags : "\"${tag}\""])
    builder       = var.builder
    awsRegion     = var.is_public_image ? "us-east-1" : data.aws_region.current.name
    ecrUrl        = local.ecr_url
    ecrSubCommand = var.is_public_image ? "ecr-public" : "ecr"
  })

  docker_buildspec_file = templatefile("${path.module}/docker_buildspec.yml", {
    imageName     = local.image_name
    imageTags     = join(" ", [for tag in local.image_tags : "\"${tag}\""])
    awsRegion     = var.is_public_image ? "us-east-1" : data.aws_region.current.name
    ecrUrl        = local.ecr_url
    ecrSubCommand = var.is_public_image ? "ecr-public" : "ecr"
  })

  buildspec_file = var.build_with_docker ? local.docker_buildspec_file : local.pack_buildspec_file

}

resource "random_pet" "generated_image_name" {
  count  = var.image_name != null ? 0 : 1
  length = 2
  prefix = basename(var.source_dir)
}

resource "aws_ecr_repository" "private" {
  count        = var.is_public_image ? 0 : 1
  name         = local.image_name
  force_delete = var.force_delete_repository

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecrpublic_repository" "public" {
  count           = var.is_public_image ? 1 : 0
  provider        = aws.us-east-1
  repository_name = local.image_name
}

data "aws_region" "current" {}

resource "aws_codecommit_repository" "app" {
  repository_name = local.image_name
  description     = "Source code for ${local.image_name} image"
}

resource "terraform_data" "push" {
  triggers_replace = [
    data.external.last_commit.result.hash,
    data.external.current_branch.result.branch,
    var.codecommit_username,
    var.codecommit_password_key,
    aws_codecommit_repository.app.clone_url_http
  ]

  provisioner "local-exec" {
    command = templatefile("${path.module}/push.tpl", {
      projectDir     = var.source_dir
      repositoryUrl  = aws_codecommit_repository.app.clone_url_http
      gitUsername    = var.codecommit_username
      gitPasswordKey = var.codecommit_password_key
    })
  }
}

resource "terraform_data" "build" {
  triggers_replace = [
    data.external.last_commit.result.hash,
    data.external.current_branch.result.branch,
    local.buildspec_file,
  ]

  provisioner "local-exec" {
    command = templatefile("${path.module}/build.tpl", {
      projectName = aws_codebuild_project.docker_build.name
    })
    interpreter = ["bash", "-c"]
  }

  depends_on = [terraform_data.push]
}


resource "aws_codebuild_project" "docker_build" {
  name         = "docker-build-${local.image_name}"
  description  = "Builds the ${local.image_name} docker image"
  service_role = aws_iam_role.docker_build.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "CODECOMMIT"
    location  = aws_codecommit_repository.app.clone_url_http
    buildspec = local.buildspec_file
  }
  source_version = data.external.current_branch.result.branch

  logs_config {
    cloudwatch_logs {
      group_name  = "codebuild-${local.image_name}-build"
      stream_name = "codebuild-${local.image_name}-log-stream"
    }
  }
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "docker_build" {
  name               = "AWSCodeBuildDockerBuild-${local.image_name}"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}


data "aws_iam_policy_document" "docker_build" {
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["codecommit:GitPull"]
    resources = [aws_codecommit_repository.app.arn]
  }

  statement {
    effect  = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetAuthorizationToken",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr-public:BatchCheckLayerAvailability",
      "ecr-public:CompleteLayerUpload",
      "ecr-public:GetAuthorizationToken",
      "ecr-public:InitiateLayerUpload",
      "ecr-public:PutImage",
      "ecr-public:UploadLayerPart",
      "sts:GetServiceBearerToken"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "docker_build" {
  role   = aws_iam_role.docker_build.name
  policy = data.aws_iam_policy_document.docker_build.json
}
