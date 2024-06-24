# ---------------------------------------------------------------------------------------------------------------------
# APPRUNNER Service
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_apprunner_service" "service" {
  service_name = var.service_name
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
      }
    }
  }
  instance_configuration {
    instance_role_arn = var.instance_iam_arn
  }
  tags = var.tags
}

resource "aws_apprunner_custom_domain_association" "dino_api_custom" {
  domain_name = var.service_custom_domain
  service_arn = aws_apprunner_service.service.arn
}

output "apprunner_service_url" {
  value = "https://${aws_apprunner_service.service.service_url}"
}
