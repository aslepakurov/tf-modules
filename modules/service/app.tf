# ---------------------------------------------------------------------------------------------------------------------
# APPRUNNER Service
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_apprunner_auto_scaling_configuration_version" "service_auto_scaling" {
  auto_scaling_configuration_name = "${var.service_name}-auto-scaling"
  max_concurrency                 = var.max_concurrency
  max_size                        = var.max_workers
  min_size                        = var.min_workers
}

resource "aws_apprunner_service" "service" {
  service_name = var.service_name
  auto_scaling_configuration_arn = aws_apprunner_auto_scaling_configuration_version.service_auto_scaling.arn
  source_configuration {
    authentication_configuration {
      access_role_arn = var.access_iam_arn
    }
    image_repository {
      image_identifier      = "${var.service_image_name}:${var.service_image_version}"
      image_repository_type = "ECR"
      image_configuration {
        port                          = var.service_port
        runtime_environment_variables = var.env
        runtime_environment_secrets   = var.secret_env
      }
    }
  }
  instance_configuration {
    instance_role_arn = var.instance_iam_arn
  }
  tags = var.tags
}

resource "aws_apprunner_custom_domain_association" "service_custom_domain" {
  domain_name = var.service_custom_domain
  service_arn = aws_apprunner_service.service.arn
}

output "apprunner_service_url" {
  value = "https://${aws_apprunner_service.service.service_url}"
}
