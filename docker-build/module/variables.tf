variable "source_dir" {
  description = "The directory where the source code is located"
  type        = string
}

variable "codecommit_password_key" {
  description = "The name of the key in SSM Parameter Store that contains the CodeCommit password"
}

variable "codecommit_username" {
  description = "The username to use when authenticating to CodeCommit"
}

variable "image_name" {
  description = "name of the docker image to build without the namespace. Uses the project dir name by default"
  type        = string
  default     = null
}

variable "image_tags" {
  description = "tag of the docker image to build"
  type        = list(string)
  default     = null
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

variable "force_delete_repository" {
  description = "If true, the ECR repository will be deleted on destroy even if it contains images"
  type        = bool
  default     = false
}
