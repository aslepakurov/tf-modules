# ---------------------------------------------------------------------------------------------------------------------
# Example: App with Database
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------------------------------------------------------------------
# Network Module
# ---------------------------------------------------------------------------------------------------------------------

module "network" {
  source = "../../modules/network"

  aws_region  = var.aws_region
  aws_project = var.project_name
  vpc_cidr    = var.vpc_cidr
  az_count    = var.az_count
  tags        = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Database Module
# ---------------------------------------------------------------------------------------------------------------------

module "database" {
  source = "../../modules/database"

  identifier = "${var.project_name}-db"
  engine     = "postgres"
  db_name    = var.db_name
  username   = var.db_username
  password   = var.db_password

  # Network configuration - use private subnets for security
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.private_subnet_ids

  # Security configuration - make it private
  publicly_accessible = false
  
  # Only allow access from the app's security group
  security_group_ingress_security_groups = [module.app.app_security_group_id]
  
  # No direct access from any CIDR blocks
  security_group_ingress_cidr_blocks = []

  tags = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# App Module
# ---------------------------------------------------------------------------------------------------------------------

module "app" {
  source = "../../modules/service"

  service_name         = "${var.project_name}-app"
  service_image_name   = var.app_image_name
  service_image_version = var.app_image_version
  service_custom_domain = var.app_custom_domain
  
  # IAM roles
  instance_iam_arn = var.app_instance_iam_arn
  access_iam_arn   = var.app_access_iam_arn
  
  # Network configuration - use the same VPC as the database
  vpc_id     = module.network.vpc_id
  subnet_ids = module.network.private_subnet_ids
  
  # Database connection
  db_connection_url = module.database.db_connection_url
  
  tags = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------------------------------------------------

output "app_url" {
  description = "The URL of the deployed app"
  value       = module.app.apprunner_service_url
}

output "database_endpoint" {
  description = "The endpoint of the database"
  value       = module.database.db_instance_endpoint
}