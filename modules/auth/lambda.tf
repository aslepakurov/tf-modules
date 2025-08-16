# ---------------------------------------------------------------------------------------------------------------------
# Lambda Function for Cognito Post-Confirmation (Docker-based)
# ---------------------------------------------------------------------------------------------------------------------

locals {
  lambda_function_name = "${var.project_name}-cognito-post-confirmation"
  create_lambda_role   = local.create_lambda && var.lambda_role_arn == ""
  ecr_repository_name  = "${var.project_name}-cognito-post-confirmation"
  image_tag            = "latest"
  use_custom_image     = var.lambda_ecr_image_uri != ""

  # Define dependencies for Lambda function
  lambda_basic_dependencies = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy_attachment.lambda_vpc_access,
    aws_iam_role_policy_attachment.lambda_rds_policy_attachment
  ]

  lambda_ecr_dependencies = local.use_custom_image ? [] : [aws_ecr_repository.lambda_ecr_repo[0]]
}

# ECR Repository for Docker image
resource "aws_ecr_repository" "lambda_ecr_repo" {
  count = local.create_lambda && !local.use_custom_image ? 1 : 0
  name  = local.ecr_repository_name
  image_scanning_configuration {
    scan_on_push = true
  }
}

# IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  count = local.create_lambda_role ? 1 : 0
  name  = "${local.lambda_function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for Lambda to access RDS
resource "aws_iam_policy" "lambda_rds_policy" {
  count       = local.create_lambda_role ? 1 : 0
  name        = "${local.lambda_function_name}-rds-policy"
  description = "IAM policy for Lambda to access RDS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "rds:Connect",
          "rds:DescribeDBInstances"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach the RDS policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_rds_policy_attachment" {
  count      = local.create_lambda_role ? 1 : 0
  role       = aws_iam_role.lambda_role[0].name
  policy_arn = aws_iam_policy.lambda_rds_policy[0].arn
}

# Attach the basic Lambda execution policy to the role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  count      = local.create_lambda_role ? 1 : 0
  role       = aws_iam_role.lambda_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Attach the VPC access policy to the role if VPC configuration is provided
resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  count      = local.create_lambda_role && length(var.subnet_ids) > 0 ? 1 : 0
  role       = aws_iam_role.lambda_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Lambda function
resource "aws_lambda_function" "post_confirmation" {
  count         = local.create_lambda ? 1 : 0
  function_name = local.lambda_function_name
  description   = "Docker-based Lambda function to insert user data into RDS after Cognito sign-up"
  role          = local.create_lambda_role ? aws_iam_role.lambda_role[0].arn : var.lambda_role_arn
  timeout       = 30
  memory_size   = 128

  # Use Docker image instead of zip file
  package_type = "Image"
  image_uri    = local.use_custom_image ? var.lambda_ecr_image_uri : "${aws_ecr_repository.lambda_ecr_repo[0].repository_url}:${local.image_tag}"

  environment {
    variables = {
      RDS_URL      = var.rds_url
      RDS_DB_NAME  = var.rds_db_name
      RDS_USERNAME = var.rds_username
      RDS_PASSWORD = var.rds_password
    }
  }

  # VPC configuration if subnet IDs are provided
  dynamic "vpc_config" {
    for_each = length(var.subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = length(var.security_group_ids) > 0 ? var.security_group_ids : null
    }
  }

  depends_on = concat(local.lambda_basic_dependencies, local.lambda_ecr_dependencies)
}

# Lambda trigger is now configured directly in the Cognito user pool resource

# Permission for Cognito to invoke the Lambda function
resource "aws_lambda_permission" "allow_cognito" {
  count         = local.create_lambda ? 1 : 0
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_confirmation[0].function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.user_pool.arn
}
