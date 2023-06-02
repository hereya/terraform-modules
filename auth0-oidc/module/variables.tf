variable "root_url" {
  type        = string
  description = "The base url of the application"
}

variable "app_name_prefix" {
  type        = string
  description = "Prefix for the application name"
  default     = null
}

variable "callback_path" {
  type        = string
  description = "Application callback path for authorization code grant"
  default     = "/auth/callback"
}

variable "logout_redirect_path" {
  type        = string
  description = "Application path to redirect to after logout"
  default     = "/auth/login"
}

variable "auth0_custom_domain" {
  type        = string
  description = "Auth0 tenant custom domain"
}
