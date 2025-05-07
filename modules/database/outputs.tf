# ---------------------------------------------------------------------------------------------------------------------
# RDS PostgreSQL Instance Outputs
# ---------------------------------------------------------------------------------------------------------------------


output "db_instance_endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_instance_username" {
  description = "The master username for the database"
  value       = aws_db_instance.this.username
  sensitive   = true
}

output "db_instance_port" {
  description = "The database port"
  value       = aws_db_instance.this.port
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.this.db_name
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}

output "db_security_group_id" {
  description = "The security group ID associated with the database"
  value       = aws_security_group.this.id
}

output "db_connection_url" {
  description = "The connection URL for the database in the format postgresql://username:password@endpoint:port/dbname"
  value       = "postgresql://${aws_db_instance.this.username}:${aws_db_instance.this.password}@${aws_db_instance.this.endpoint}/${aws_db_instance.this.db_name}"
  sensitive   = true
}
