variable "domain_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "AWS tags"
  default     = {}
}