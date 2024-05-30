variable "iam_user_name" {
  type        = string
  description = "IAM user name"
}

variable "iam_user_path" {
  type        = string
  default     = "/"
  description = "IAM user path"
}

variable "policy_files" {
  type        = map(string)
  default     = {}
  description = "IAM policy file paths"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "AWS tags"
}