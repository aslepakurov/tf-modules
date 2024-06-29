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

variable "tags" {
  type        = map(string)
  description = "AWS tags"
  default     = {}
}