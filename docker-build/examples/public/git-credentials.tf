resource "random_pet" "git_iam_user" {
  length    = 1
  separator = "-"
  prefix    = "codecommit-user"
}

resource "aws_iam_user" "git" {
  name = random_pet.git_iam_user.id
}

resource "aws_iam_user_policy" "git_codecommit" {
  policy = data.aws_iam_policy_document.allow_codecommit.json
  user   = aws_iam_user.git.name
}

data "aws_iam_policy_document" "allow_codecommit" {
  statement {
    effect  = "Allow"
    actions = [
      "codecommit:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_service_specific_credential" "git_codecommit" {
  service_name = "codecommit.amazonaws.com"
  user_name    = aws_iam_user.git.name
}

resource "aws_ssm_parameter" "codecommit_password" {
  name = "/codecommit/${random_pet.git_iam_user.id}/password"
  type = "SecureString"
  value = aws_iam_service_specific_credential.git_codecommit.service_password
}