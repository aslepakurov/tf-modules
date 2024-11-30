locals {
  user_pool = "${var.project_name}-user-pool"
}

resource "aws_cognito_user_pool" "user_pool" {
  name                     = local.user_pool
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message        = "Your verification code is {####}"
    email_subject        = "${var.project_name} verification code"
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  mfa_configuration = "OPTIONAL"

  software_token_mfa_configuration {
    enabled = true
  }

  schema {
    name                     = "is_dev"
    attribute_data_type      = "Boolean"
    developer_only_attribute = false
    mutable                  = true
    required                 = false
  }


}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  for_each = var.app_clients

  name            = each.value.name
  user_pool_id    = aws_cognito_user_pool.user_pool.id
  generate_secret = each.value.generate_secret

  explicit_auth_flows = each.value.explicit_auth_flows

  access_token_validity  = each.value.access_token_validity
  refresh_token_validity = each.value.refresh_token_validity
  id_token_validity      = each.value.id_token_validity

  token_validity_units {
    access_token  = each.value.access_token_units
    id_token      = each.value.id_token_units
    refresh_token = each.value.refresh_token_units
  }
}
# resource "aws_cognito_user_pool_client" "ui_client" {
#   prevent_user_existence_errors = "ENABLED"
#   //todo: limit scope for auth
#   explicit_auth_flows           = [
#     "ALLOW_USER_PASSWORD_AUTH",
#     "ALLOW_REFRESH_TOKEN_AUTH",
#     "ALLOW_USER_SRP_AUTH"
#   ]
#
#   callback_urls = var.callback_urls
#   logout_urls   = var.logout_urls
# }
#
# resource "aws_cognito_user_pool_client" "api_client" {
#   name = "${var.project_name}-api"
#
#   user_pool_id                  = aws_cognito_user_pool.user_pool.id
#   generate_secret               = true
#   refresh_token_validity        = 90
#   prevent_user_existence_errors = "ENABLED"
#   //todo: limit scope for auth
#   explicit_auth_flows           = [
#     "ALLOW_REFRESH_TOKEN_AUTH",
#     "ALLOW_USER_PASSWORD_AUTH",
#   ]
#
# }
#
# resource "aws_cognito_user_pool_client" "test_api_client" {
#   name = "${var.project_name}-test"
#
#   user_pool_id                  = aws_cognito_user_pool.user_pool.id
#   generate_secret               = false
#   prevent_user_existence_errors = "ENABLED"
#
#   access_token_validity  = 5
#   refresh_token_validity = 60
#   id_token_validity      = 5
#
#   token_validity_units {
#     access_token  = "minutes"
#     id_token      = "minutes"
#     refresh_token = "minutes"
#   }
#   //todo: limit scope for auth
#   explicit_auth_flows           = [
#     "ALLOW_REFRESH_TOKEN_AUTH",
#     "ALLOW_USER_PASSWORD_AUTH",
#   ]
#
# }