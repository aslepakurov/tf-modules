variable "project_name" {
  type = string
  description = "Project prefix"
}

variable "custom_domain" {
  type = string
  default = ""
}

variable "cert_arn" {
  type = string
  default = ""
}

variable "callback_urls" {
  type    = list(string)
  default = []
  description = "List of callback redirect urls"
}

variable "logout_urls" {
  type    = list(string)
  default = []
  description = "List of logout urls"
}

variable "app_clients" {
  default = []
  description = "List of cognito app clients"
  type    = list(object({
    name = string
    description = optional(string, "")
    generate_secret = optional(bool, false)
    explicit_auth_flows = optional(list(string), [
      "ALLOW_REFRESH_TOKEN_AUTH",
      "ALLOW_USER_PASSWORD_AUTH",
    ])
    callback_urls = optional(list(string), [])
    logout_urls = optional(list(string), [])

    // validity
    access_token_validity = optional(number, 3600)
    refresh_token_validity = optional(number, 10)
    id_token_validity = optional(number, 60)

    // validity units
    access_token_units = optional(string, "seconds")
    id_token_units = optional(string, "minutes")
    refresh_token_units = optional(string, "days")
  }))
}

variable "password_policy" {
  description = "Password policy for user pool user"
  default = {
    minimum_length                   = 12
    require_lowercase                = false
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 14
  }
  type = object({
    minimum_length                   = optional(number, 12)
    require_lowercase                = optional(bool, false)
    require_uppercase                = optional(bool, true)
    require_numbers                  = optional(bool, true)
    require_symbols                  = optional(bool, true)
    temporary_password_validity_days = optional(number, 14)
  })
}

variable "username_attributes" {
  type    = list(string)
  default = ["email"]
}

variable "auto_verified_attributes" {
  type    = list(string)
  default = ["email"]
}