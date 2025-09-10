# ---------------------------------------------------------------------------------------------------------------------
# Network Module Outputs
# ---------------------------------------------------------------------------------------------------------------------

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = aws_route_table.private-route-table[*].id
}

output "private_route_table_id" {
  description = "ID of the first private route table (for backward compatibility)"
  value       = aws_route_table.private-route-table[0].id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public-route-table.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "cognito_vpc_endpoint_id" {
  description = "The ID of the Cognito VPC endpoint"
  value       = aws_vpc_endpoint.cognito.id
}

output "dynamodb_vpc_endpoint_id" {
  description = "The ID of the DynamoDB VPC endpoint"
  value       = aws_vpc_endpoint.dynamodb.id
}
