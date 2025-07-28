# Network Module

This module creates a VPC with public and private subnets across multiple availability zones, along with the necessary routing and gateways.

## Cost Optimization for NAT Gateways

NAT Gateways are one of the most expensive components in AWS networking infrastructure. This module provides options to optimize costs while balancing availability requirements:

### Single NAT Gateway (Default, Cost-Effective)

By default, this module creates a single NAT Gateway for all private subnets across all availability zones. This significantly reduces costs compared to deploying one NAT Gateway per AZ.

**Benefits:**
- Lower cost (approximately 60-70% savings with 2 AZs, more with 3+ AZs)
- Still provides internet access for resources in private subnets

**Trade-offs:**
- Reduced availability: If the AZ containing the NAT Gateway fails, resources in private subnets in all AZs will lose internet access
- Potential for cross-AZ data transfer costs

### Multiple NAT Gateways (Higher Availability)

For production environments where high availability is critical, you can deploy one NAT Gateway per AZ.

**Benefits:**
- Higher availability: If one AZ fails, resources in other AZs will still have internet access
- No cross-AZ data transfer costs

**Trade-offs:**
- Higher cost (one NAT Gateway per AZ)

## Usage

```hcl
module "network" {
  source = "../../modules/network"

  aws_region  = "us-west-2"
  aws_project = "my-project"
  
  # Cost optimization settings
  enable_nat_gateway = true     # Set to false to disable NAT Gateways entirely
  single_nat_gateway = true     # Set to false for higher availability (but higher cost)
  
  # Other settings
  az_count    = 2
  vpc_cidr    = "10.0.0.0/16"
  tags        = { Environment = "Production" }
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws_region | The AWS region to deploy resources | `string` | n/a | yes |
| aws_project | Top level project name | `string` | n/a | yes |
| az_count | Number of AZs to cover in a given AWS region | `number` | `2` | no |
| vpc_cidr | CIDR for the VPC | `string` | `"172.17.0.0/16"` | no |
| enable_nat_gateway | Should be true if you want to provision NAT Gateways for your private networks | `bool` | `true` | no |
| single_nat_gateway | Should be true if you want to provision a single shared NAT Gateway across all of your private networks (cost-effective but less redundant) | `bool` | `true` | no |
| tags | AWS tags | `map(string)` | `{}` | no |