output "OIDC_CLIENT_ID" {
  value = aws_cognito_user_pool_client.client.id
}

output "OIDC_CLIENT_SECRET" {
  value = {
    type   = "ssm"
    key    = aws_ssm_parameter.client_secret.name
    region = data.aws_region.current.name
    arn    = aws_ssm_parameter.client_secret.arn
  }
}

output "OIDC_ISSUER_URL" {
  value = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${var.cognito_user_pool_id}"
}

output "OIDC_DISCOVERY_URL" {
  value = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${var.cognito_user_pool_id}/.well-known/openid-configuration"
}

output "OIDC_LOGOUT_URL" {
  value = "${var.cognito_user_pool_domain}/logout"
}

output "OIDC_LOGOUT_REDIRECT_URL" {
  value = tolist(aws_cognito_user_pool_client.client.logout_urls)[0]
}

output "OIDC_CALLBACK_URL" {
  value = tolist(aws_cognito_user_pool_client.client.callback_urls)[0]
}