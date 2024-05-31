variable "iam_role_name" {
  type        = string
  description = "IAM role name"
}

variable "iam_role_description" {
  type        = string
  default     = ""
  description = "IAM role description"
}

variable "iam_role_max_session" {
  type        = number
  default     = 43200
  description = "Maximum session duration in seconds"
  validation {
    condition     = var.iam_role_max_session >= 3600 && var.iam_role_max_session <= 43200
    error_message = "Max session is outside boundaries [3600, 43200]"
  }
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

variable "assume_role_principal" {
  type        = map(string)
  description = "IAM Principal for role assume"
}