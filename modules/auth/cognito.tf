terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}
locals {
  user_pool = "${var.project_name}-user-pool"
}

resource "aws_cognito_user_pool" "user_pool" {
  name                     = local.user_pool
  username_attributes      = var.username_attributes
  auto_verified_attributes = var.auto_verified_attributes
  deletion_protection      = "ACTIVE"

  //TODO: set up non-default email
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message        = "Your verification code is {####}"
    email_subject        = "${var.project_name} verification code"
  }

  password_policy {
    minimum_length                   = var.password_policy.minimum_length
    require_lowercase                = var.password_policy.require_lowercase
    require_uppercase                = var.password_policy.require_uppercase
    require_numbers                  = var.password_policy.require_numbers
    require_symbols                  = var.password_policy.require_symbols
    temporary_password_validity_days = var.password_policy.temporary_password_validity_days
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

resource "aws_cognito_user_pool_domain" "cognito_custom_domain" {
  count        = var.custom_domain == "" ? 0 : 1
  domain       = var.custom_domain
  user_pool_id = aws_cognito_user_pool.user_pool.id
  certificate_arn = var.cert_arn
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  for_each =  { for app_client in var.app_clients : app_client.name => app_client }

  name            = each.key
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

  callback_urls = each.value.callback_urls
  logout_urls = each.value.logout_urls
}