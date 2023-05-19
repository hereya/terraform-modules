output "OIDC_CLIENT_ID" {
  value = module.cognito_app.OIDC_CLIENT_ID
}

output "OIDC_CLIENT_SECRET" {
  value = module.cognito_app.OIDC_CLIENT_SECRET
}

output "OIDC_ISSUER_URL" {
  value = module.cognito_app.OIDC_ISSUER_URL
}

output "OIDC_DISCOVERY_URL" {
  value = module.cognito_app.OIDC_DISCOVERY_URL
}

output "OIDC_LOGOUT_URL" {
  value = module.cognito_app.OIDC_LOGOUT_URL
}

output "OIDC_LOGOUT_REDIRECT_URL" {
  value = module.cognito_app.OIDC_LOGOUT_REDIRECT_URL
}

output "OIDC_CALLBACK_URL" {
  value = module.cognito_app.OIDC_CALLBACK_URL
}