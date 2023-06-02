output "OIDC_CLIENT_ID" {
  value = auth0_client.client.client_id
}

output "OIDC_CLIENT_SECRET" {
  value = {
    type   = "ssm"
    arn    = aws_ssm_parameter.client_secret.arn
    key    = aws_ssm_parameter.client_secret.name
    region = data.aws_region.current.name
  }
}

output "OIDC_ISSUER_URL" {
  value = "https://${var.auth0_custom_domain}"
}

output "OIDC_DISCOVERY_URL" {
  value = "https://${var.auth0_custom_domain}/.well-known/openid-configuration"
}

output "OIDC_LOGOUT_URL" {
  value = "https://${var.auth0_custom_domain}/v2/logout"
}

output "OIDC_LOGOUT_REDIRECT_URL" {
  value = "${var.root_url}${var.logout_redirect_path}"
}

output "OIDC_CALLBACK_URL" {
  value = "${var.root_url}${var.callback_path}"
}