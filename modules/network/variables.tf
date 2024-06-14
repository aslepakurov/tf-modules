variable "aws_region" {
  description = "The AWS region to spin infra in"
}

variable "aws_project" {
  description = "Top level project name"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "172.17.0.0/16"
}