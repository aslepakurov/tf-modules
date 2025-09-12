# ---------------------------------------------------------------------------------------------------------------------
# Network Module V2 Outputs
# ---------------------------------------------------------------------------------------------------------------------

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# ---------------------------------------------------------------------------------------------------------------------
# Subnet Outputs
# ---------------------------------------------------------------------------------------------------------------------

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

# ---------------------------------------------------------------------------------------------------------------------
# Route Table Outputs
# ---------------------------------------------------------------------------------------------------------------------

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = aws_route_table.private[*].id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

# ---------------------------------------------------------------------------------------------------------------------
# Gateway Outputs
# ---------------------------------------------------------------------------------------------------------------------

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_ids" {
  description = "List of IDs of NAT Gateways"
  value       = aws_nat_gateway.nat[*].id
}

# ---------------------------------------------------------------------------------------------------------------------
# VPC Endpoint Outputs
# ---------------------------------------------------------------------------------------------------------------------

output "dynamodb_vpc_endpoint_id" {
  description = "The ID of the DynamoDB VPC endpoint"
  value       = aws_vpc_endpoint.dynamodb.id
}

# ---------------------------------------------------------------------------------------------------------------------
# Security Group Outputs
# ---------------------------------------------------------------------------------------------------------------------

output "apprunner_connector_security_group_id" {
  description = "ID of the security group for App Runner VPC connector"
  value       = var.create_apprunner_security_group ? aws_security_group.apprunner_connector[0].id : null
}

output "rds_security_group_id" {
  description = "ID of the security group for RDS instances"
  value       = var.create_rds_security_group ? aws_security_group.rds[0].id : null
}

# ---------------------------------------------------------------------------------------------------------------------
# App Runner Connectivity Outputs
# ---------------------------------------------------------------------------------------------------------------------

output "apprunner_vpc_connector_subnets" {
  description = "List of subnet IDs to use for App Runner VPC connector (private subnets)"
  value       = aws_subnet.private[*].id
}

output "apprunner_vpc_connector_security_groups" {
  description = "List of security group IDs to use for App Runner VPC connector"
  value       = var.create_apprunner_security_group ? [aws_security_group.apprunner_connector[0].id] : []
}
