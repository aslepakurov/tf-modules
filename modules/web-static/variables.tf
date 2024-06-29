variable "domain_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "default_page" {
  type    = string
  default = "index.html"
}

variable "error_page" {
  type    = string
  default = "error.html"
}

variable "tags" {
  type        = map(string)
  description = "AWS tags"
  default     = {}
}

variable "aliases" {
  type = list(string)
  default = []
}

variable "certificate_arn" {
  type = string
  default = ""
}