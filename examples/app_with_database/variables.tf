# ---------------------------------------------------------------------------------------------------------------------
# Example Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  type        = string
  description = "The AWS region to deploy resources in"
  default     = "us-west-2"
}

variable "project_name" {
  type        = string
  description = "The name of the project"
  default     = "example"
}

# ---------------------------------------------------------------------------------------------------------------------
# Network Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "az_count" {
  type        = number
  description = "Number of AZs to cover in a given AWS region"
  default     = 2
}

# ---------------------------------------------------------------------------------------------------------------------
# Database Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "db_name" {
  type        = string
  description = "The name of the database"
  default     = "exampledb"
}

variable "db_username" {
  type        = string
  description = "The username for the database"
  default     = "dbadmin"
}

variable "db_password" {
  type        = string
  description = "The password for the database"
  sensitive   = true
}

# ---------------------------------------------------------------------------------------------------------------------
# App Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "app_image_name" {
  type        = string
  description = "The name of the app image"
}

variable "app_image_version" {
  type        = string
  description = "The version of the app image"
  default     = "latest"
}

variable "app_custom_domain" {
  type        = string
  description = "The custom domain for the app"
}

variable "app_instance_iam_arn" {
  type        = string
  description = "The ARN of the IAM role for the app instance"
}

variable "app_access_iam_arn" {
  type        = string
  description = "The ARN of the IAM role for app access"
}

# ---------------------------------------------------------------------------------------------------------------------
# Common Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {
    Environment = "example"
    Terraform   = "true"
  }
}