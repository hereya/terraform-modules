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

data "external" "committed_source_files" {
  program = ["bash", "${abspath(path.module)}/committed_source_files.sh"]
  working_dir = var.source_dir
}

locals {
  image_name     = var.image_name != null ? var.image_name : random_pet.generated_image_name.0.id
  s3_object_key  = "${local.image_name}/${var.image_tags[0]}/${random_pet.project_source_s3_name.id}.zip"
  repository_url = var.is_public_image ? aws_ecrpublic_repository.public.0.repository_uri : aws_ecr_repository.private.0.repository_url
  ecr_url        = dirname(local.repository_url)
  source_files   = {
    for file in sort(split(",", data.external.committed_source_files.result.files)) :
    file => "${var.source_dir}/${file}"
  }
  buildspec_file = templatefile("${path.module}/buildspec.yml", {
    imageName     = local.image_name
    imageTags     = join(" ", [for tag in var.image_tags : "\"${tag}\""])
    builder       = var.builder
    awsRegion     = var.is_public_image ? "us-east-1" : data.aws_region.current.name
    ecrUrl        = local.ecr_url
    ecrSubCommand = var.is_public_image ? "ecr-public" : "ecr"
  })
  source_file_hashes = merge({
    for file, full_path in local.source_files :
    file => filebase64sha512(full_path)
  },
    {
      "buildspec.yml" = base64sha512(local.buildspec_file)
    }
  )
  source_dir_hash = base64sha512(jsonencode(local.source_file_hashes))
}

resource "random_pet" "generated_image_name" {
  count  = var.image_name != null ? 0 : 1
  length = 2
  prefix = basename(var.source_dir)
}

resource "aws_ecr_repository" "private" {
  count = var.is_public_image ? 0 : 1
  name  = local.image_name

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


data "archive_file" "project_source" {
  type = "zip"

  dynamic "source" {
    for_each = local.source_files
    content {
      filename = source.key
      content  = file(source.value)
    }
  }

  source {
    filename = "buildspec.yml"
    content  = local.buildspec_file
  }

  output_path = ".source.zip"
}

resource "random_pet" "project_source_s3_name" {
  keepers = {
    source_hash = local.source_dir_hash
  }
  length = 2
}

resource "aws_s3_object" "project_source" {
  bucket      = var.source_bucket
  key         = local.s3_object_key
  source      = data.archive_file.project_source.output_path
  source_hash = local.source_dir_hash
}

resource "terraform_data" "build" {
  triggers_replace = [
    aws_s3_object.project_source.version_id,
  ]

  provisioner "local-exec" {
    command = templatefile("${path.module}/build.tpl", {
      projectName = aws_codebuild_project.docker_build.name
    })
  }
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
    type     = "S3"
    location = "${var.source_bucket}/${local.s3_object_key}"
  }

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

data "aws_s3_bucket" "source" {
  bucket = var.source_bucket
}
data "aws_iam_policy_document" "docker_build" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = [
      data.aws_s3_bucket.source.arn,
      "${data.aws_s3_bucket.source.arn}/*",
    ]
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
