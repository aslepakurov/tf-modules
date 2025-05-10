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

    // OAuth settings
    allowed_oauth_flows = optional(list(string), [])
    allowed_oauth_flows_user_pool_client = optional(bool, false)
    allowed_oauth_scopes = optional(list(string), [])
    supported_identity_providers = optional(list(string), ["COGNITO"])

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

# Lambda function variables
variable "enable_post_confirmation_lambda" {
  description = "Whether to create a Lambda function that inserts user data into RDS after Cognito sign-up"
  type        = bool
  default     = false
}

variable "lambda_role_arn" {
  description = "ARN of the IAM role for the Lambda function to use. If not provided, a new role will be created."
  type        = string
  default     = ""
}

variable "rds_url" {
  description = "RDS URL with schema, host, and port (e.g., postgresql://hostname:5432)"
  type        = string
  default     = ""
}

variable "rds_db_name" {
  description = "RDS database name"
  type        = string
  default     = ""
}

variable "rds_username" {
  description = "RDS username"
  type        = string
  default     = ""
  sensitive   = true
}

variable "rds_password" {
  description = "RDS password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "vpc_id" {
  description = "VPC ID for Lambda function"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of subnet IDs for Lambda function"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs for Lambda function"
  type        = list(string)
  default     = []
}
