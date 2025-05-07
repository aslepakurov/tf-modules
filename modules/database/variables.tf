variable "identifier" {
  type        = string
  description = "The name of the RDS instance"
}

variable "engine" {
  type        = string
  description = "The database engine to use"
  default     = "postgres"
}

variable "engine_version" {
  type        = string
  description = "The engine version to use"
  default     = "14.6"
}

variable "instance_class" {
  type        = string
  description = "The instance type of the RDS instance. Use db.t3.micro for dev/test environments and db.t3.small or larger for production."
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  type        = number
  description = "The amount of allocated storage in gigabytes"
  default     = 20
}

variable "max_allocated_storage" {
  type        = number
  description = "The upper limit to which Amazon RDS can automatically scale the storage of the DB instance. Set to 0 to disable auto-scaling. For cost control, set a reasonable limit based on expected growth."
  default     = 50
}

variable "storage_type" {
  type        = string
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)"
  default     = "gp2"
}

variable "storage_encrypted" {
  type        = bool
  description = "Specifies whether the DB instance is encrypted"
  default     = true
}

variable "kms_key_id" {
  type        = string
  description = "The ARN for the KMS encryption key. If creating an encrypted replica, set this to the destination KMS ARN"
  default     = null
}

variable "username" {
  type        = string
  description = "Username for the master DB user"
}

variable "password" {
  type        = string
  description = "Password for the master DB user"
  sensitive   = true
}

variable "port" {
  type        = number
  description = "The port on which the DB accepts connections"
  default     = 5432
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the RDS instance will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of VPC subnet IDs to place the RDS instance in"
}

variable "publicly_accessible" {
  type        = bool
  description = "Bool to control if instance is publicly accessible"
  default     = false
}

variable "allow_major_version_upgrade" {
  type        = bool
  description = "Indicates that major version upgrades are allowed"
  default     = false
}

variable "auto_minor_version_upgrade" {
  type        = bool
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
  default     = true
}

variable "apply_immediately" {
  type        = bool
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  default     = false
}

variable "maintenance_window" {
  type        = string
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'"
  default     = "Mon:00:00-Mon:03:00"
}

variable "backup_window" {
  type        = string
  description = "The daily time range during which automated backups are created if automated backups are enabled"
  default     = "03:00-06:00"
}

variable "backup_retention_period" {
  type        = number
  description = "The days to retain backups for"
  default     = 7
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted"
  default     = false
}

variable "final_snapshot_identifier_prefix" {
  type        = string
  description = "The name which is prefixed to the final snapshot on cluster destroy"
  default     = "final"
}

variable "deletion_protection" {
  type        = bool
  description = "The database can't be deleted when this value is set to true"
  default     = true
}

variable "multi_az" {
  type        = bool
  description = "Specifies if the RDS instance is multi-AZ. Enabling this doubles the cost but provides high availability. Recommended for production environments but can be disabled for dev/test to save costs."
  default     = false
}

variable "parameter_group_name" {
  type        = string
  description = "Name of the DB parameter group to associate"
  default     = null
}

variable "parameter_group_family" {
  type        = string
  description = "The family of the DB parameter group"
  default     = "postgres14"
}

variable "parameters" {
  type        = list(map(string))
  description = "A list of DB parameters to apply"
  default     = []
}

variable "db_name" {
  type        = string
  description = "The DB name to create"
  default     = null
}

variable "monitoring_interval" {
  type        = number
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance"
  default     = 0
}

variable "monitoring_role_arn" {
  type        = string
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs"
  default     = null
}

variable "performance_insights_enabled" {
  type        = bool
  description = "Specifies whether Performance Insights are enabled. Enabling this incurs additional costs but provides valuable monitoring and performance analysis. Consider enabling for production environments and critical databases."
  default     = false
}

variable "performance_insights_retention_period" {
  type        = number
  description = "The amount of time in days to retain Performance Insights data"
  default     = 7
}

variable "performance_insights_kms_key_id" {
  type        = string
  description = "The ARN for the KMS key to encrypt Performance Insights data"
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to enable for exporting to CloudWatch logs"
  default     = ["postgresql", "upgrade"]
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to all resources"
  default     = {}
}

variable "security_group_ingress_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks to allow access to the database"
  default     = []
}

variable "security_group_ingress_security_groups" {
  type        = list(string)
  description = "List of security group IDs to allow access to the database"
  default     = []
}
