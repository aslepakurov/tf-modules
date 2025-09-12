# Network Module V2

This Terraform module creates a VPC with public and private subnets across multiple availability zones. It is specifically designed to support App Runner services that need to connect to RDS instances in private subnets while being accessible from the internet.

## Features

- VPC with DNS support and DNS hostnames
- Public and private subnets across multiple availability zones
- Internet Gateway for public internet access
- NAT Gateway for private subnets to access the internet
- Route tables for both public and private subnets
- VPC Endpoint for DynamoDB
- Security groups for App Runner VPC connector and RDS instances
- Support for App Runner connectivity to RDS in private subnet

## Usage

```hcl
module "network" {
  source = "../../modules/network-v2"

  aws_region  = "us-west-2"
  aws_project = "my-project"
  vpc_cidr    = "10.0.0.0/16"
  az_count    = 2
  
  # Optional: Configure NAT Gateway
  single_nat_gateway = true
  
  # Optional: Configure security groups
  create_apprunner_security_group = true
  create_rds_security_group       = true
  rds_port                        = 5432
  
  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}
```

## App Runner with RDS Example

```hcl
# Network setup
module "network" {
  source = "../../modules/network-v2"

  aws_region  = var.aws_region
  aws_project = var.project_name
  vpc_cidr    = var.vpc_cidr
  az_count    = var.az_count
  tags        = var.tags
}

# RDS setup
resource "aws_db_instance" "database" {
  # ... other RDS configuration ...
  
  # Network configuration
  vpc_security_group_ids = [module.network.rds_security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.database.name
}

resource "aws_db_subnet_group" "database" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = module.network.private_subnet_ids
}

# App Runner setup
resource "aws_apprunner_vpc_connector" "connector" {
  vpc_connector_name = "${var.project_name}-connector"
  subnets            = module.network.apprunner_vpc_connector_subnets
  security_groups    = module.network.apprunner_vpc_connector_security_groups
}

resource "aws_apprunner_service" "service" {
  # ... other App Runner configuration ...
  
  # Network configuration
  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.connector.arn
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | The AWS region to deploy resources in | `string` | n/a | yes |
| aws_project | Project name used for resource naming and tagging | `string` | n/a | yes |
| az_count | Number of AZs to cover in a given AWS region | `number` | `2` | no |
| vpc_cidr | CIDR for the VPC | `string` | `"10.0.0.0/16"` | no |
| enable_dns_support | Should be true to enable DNS support in the VPC | `bool` | `true` | no |
| enable_dns_hostnames | Should be true to enable DNS hostnames in the VPC | `bool` | `true` | no |
| single_nat_gateway | Should be true if you want to provision a single shared NAT Gateway across all of your private networks | `bool` | `true` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| rds_port | The port on which the RDS instance accepts connections | `number` | `5432` | no |
| create_rds_security_group | Whether to create a security group for RDS instances | `bool` | `true` | no |
| create_apprunner_security_group | Whether to create a security group for App Runner VPC connector | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| private_subnet_ids | List of IDs of private subnets |
| public_subnet_ids | List of IDs of public subnets |
| private_route_table_ids | List of IDs of private route tables |
| public_route_table_id | ID of the public route table |
| internet_gateway_id | ID of the Internet Gateway |
| nat_gateway_ids | List of IDs of NAT Gateways |
| dynamodb_vpc_endpoint_id | The ID of the DynamoDB VPC endpoint |
| apprunner_connector_security_group_id | ID of the security group for App Runner VPC connector |
| rds_security_group_id | ID of the security group for RDS instances |
| apprunner_vpc_connector_subnets | List of subnet IDs to use for App Runner VPC connector (private subnets) |
| apprunner_vpc_connector_security_groups | List of security group IDs to use for App Runner VPC connector |