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