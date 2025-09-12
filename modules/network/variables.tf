variable "aws_region" {
  type        = string
  description = "The AWS region to spin infra in"
}

variable "aws_project" {
  type        = string
  description = "Top level project name"
}

variable "az_count" {
  type        = number
  description = "Number of AZs to cover in a given AWS region"
  default     = 2
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
  default     = "172.17.0.0/16"
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

variable "enable_nat_gateway" {
  type        = bool
  description = "DEPRECATED: NAT Gateways are now always provisioned for private networks to ensure internet access"
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
  description = "AWS tags"
}
