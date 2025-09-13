variable "service_name" {
  type        = string
  description = "Service name"
}

variable "service_image_name" {
  type        = string
  description = "Service image name"
}

variable "service_image_version" {
  type        = string
  description = "Service image version"
}

variable "service_custom_domain" {
  type        = string
  description = "Service custom domain"
}

variable "service_port" {
  type        = number
  description = "Service port"
  default     = 8080
}

variable "instance_iam_arn" {
  type        = string
  description = "ARN for AppRunner instance role"
}

variable "access_iam_arn" {
  type        = string
  description = "ARN for AppRunner access role"
}

variable "env" {
  type        = map(string)
  description = "Map of environment variables"
  default     = {}
}

variable "secret_env" {
  type        = map(string)
  description = "Map of environment variables from Secret Manager"
  default     = {}
}

variable "max_concurrency" {
  type        = number
  description = "Max concurrency for auto scaling policy"
  default     = 200
}

variable "min_workers" {
  type        = number
  description = "Minimum amount of workers"
  default     = 1
}

variable "max_workers" {
  type        = number
  description = "Maximum amount of workers"
  default     = 3
}

variable "tags" {
  type        = map(string)
  description = "AWS tags"
  default     = {}
}

# ---------------------------------------------------------------------------------------------------------------------
# Network and Database Connection Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the service will be deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs where the service will be deployed"
}

variable "db_connection_url" {
  type        = string
  description = "Database connection URL"
  default     = null
  sensitive   = true
}
