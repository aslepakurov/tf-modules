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

variable "tags" {
  type        = map(string)
  description = "AWS tags"
  default     = {}
}