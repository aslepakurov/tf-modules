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
  service_name                   = var.service_name
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
        runtime_environment_variables = var.db_connection_url != null ?
          merge(var.env, { DATABASE_URL = var.db_connection_url }) : var.env
        runtime_environment_secrets   = var.secret_env
      }
    }
  }
  instance_configuration {
    instance_role_arn = var.instance_iam_arn
  }

  # VPC configuration if VPC ID and subnet IDs are provided
  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.connector.arn
    }
    ingress_configuration {
      is_publicly_accessible = true
    }
  }

  tags = var.tags
}

# Create VPC connector if VPC ID and subnet IDs are provided
resource "aws_apprunner_vpc_connector" "connector" {
  vpc_connector_name = "${var.service_name}-vpc-connector"
  subnets            = var.subnet_ids
  security_groups = [aws_security_group.app.id]

  tags = var.tags
}

# Create security group for the app if VPC ID is provided
resource "aws_security_group" "app" {

  name        = "${var.service_name}-sg"
  description = "Security group for ${var.service_name} AppRunner service"
  vpc_id      = var.vpc_id

  # Allow all outbound traffic
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.service_name}-sg"
  })
}

resource "aws_apprunner_custom_domain_association" "service_custom_domain" {
  domain_name = var.service_custom_domain
  service_arn = aws_apprunner_service.service.arn
}

output "apprunner_service_url" {
  value = "https://${aws_apprunner_service.service.service_url}"
}

output "app_security_group_id" {
  description = "The ID of the security group associated with the app"
  value       = aws_security_group.app.id
}
