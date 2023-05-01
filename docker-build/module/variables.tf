variable "source_dir" {
  description = "The directory where the source code is located"
  type        = string
}

variable "source_bucket" {
  description = "The name of the S3 bucket where the source code will be uploaded for codebuild"
  type        = string
}

variable "image_name" {
  description = "name of the docker image to build without the namespace. Uses the project dir name by default"
  type        = string
  default     = null
}


variable "image_tags" {
  description = "tag of the docker image to build"
  type        = list(string)
  default     = ["latest"]
}

variable "builder" {
  description = "buildpack builder to use to build the docker image"
  type        = string
  default     = "gcr.io/buildpacks/builder:v1"
}

variable "is_public_image" {
  description = "If true, the docker image will be pushed to ECR public registry instead of a private one"
  type        = bool
  default     = false
}
