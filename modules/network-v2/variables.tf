# ---------------------------------------------------------------------------------------------------------------------
# Network Module V2 Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  type        = string
  description = "The AWS region to deploy resources in"
}

variable "aws_project" {
  type        = string
  description = "Project name used for resource naming and tagging"
}

variable "az_count" {
  type        = number
  description = "Number of AZs to cover in a given AWS region"
  default     = 2
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
  default     = "10.0.0.0/16"
}

variable "enable_dns_support" {
  type        = bool
  description = "Should be true to enable DNS support in the VPC"
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Should be true to enable DNS hostnames in the VPC"
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks (cost-effective but less redundant)"
  default     = true
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to add to all resources"
}

# ---------------------------------------------------------------------------------------------------------------------
# App Runner and RDS Configuration Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "rds_port" {
  type        = number
  description = "The port on which the RDS instance accepts connections"
  default     = 5432
}

variable "create_rds_security_group" {
  type        = bool
  description = "Whether to create a security group for RDS instances"
  default     = true
}

variable "create_apprunner_security_group" {
  type        = bool
  description = "Whether to create a security group for App Runner VPC connector"
  default     = true
}