# ---------------------------------------------------------------------------------------------------------------------
# Network Module V2
# ---------------------------------------------------------------------------------------------------------------------
# This module creates a VPC with public and private subnets across multiple availability zones.
# It includes all necessary components for:
# - App Runner services that can connect to RDS via private network
# - App Runner services that can be accessed from the internet
# - App Runner applications that can connect to external internet resources
# ---------------------------------------------------------------------------------------------------------------------

data "aws_availability_zones" "available" {}

# ---------------------------------------------------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, {
    Name = "${var.aws_project}-VPC"
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# PRIVATE SUBNETS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(var.tags, {
    Name = "${var.aws_project}-PrivateSubnet-${count.index + 1}"
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# PUBLIC SUBNETS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_subnet" "public" {
  count                   = var.az_count
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, var.az_count + count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name = "${var.aws_project}-PublicSubnet-${count.index + 1}"
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# INTERNET GATEWAY
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, {
    Name = "${var.aws_project}-IGW"
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# ROUTE TABLE FOR PUBLIC SUBNETS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, {
    Name = "${var.aws_project}-PublicRouteTable"
  })
}

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_route_table.public, aws_subnet.public]
}

# ---------------------------------------------------------------------------------------------------------------------
# NAT GATEWAY FOR PRIVATE SUBNET INTERNET ACCESS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_eip" "nat" {
  count  = var.single_nat_gateway ? 1 : var.az_count
  domain = "vpc"
  tags = merge(var.tags, {
    Name = "${var.aws_project}-NAT-EIP-${count.index + 1}"
  })
}

resource "aws_nat_gateway" "nat" {
  count         = var.single_nat_gateway ? 1 : var.az_count
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  tags = merge(var.tags, {
    Name = "${var.aws_project}-NAT-${count.index + 1}"
  })
  depends_on = [aws_internet_gateway.igw]
}

# ---------------------------------------------------------------------------------------------------------------------
# PRIVATE ROUTE TABLE (WITH INTERNET ACCESS VIA NAT GATEWAY)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  # Route all internet-bound traffic through the NAT gateway
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat.*.id, var.single_nat_gateway ? 0 : count.index)
  }

  tags = merge(var.tags, {
    Name = "${var.aws_project}-PrivateRouteTable-${count.index + 1}"
  })
}

resource "aws_route_table_association" "private" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_route_table.private, aws_subnet.private]
}

# ---------------------------------------------------------------------------------------------------------------------
# VPC ENDPOINT FOR DYNAMODB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private[*].id

  tags = merge(var.tags, {
    Name = "${var.aws_project}-DynamoDBEndpoint"
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUP FOR APP RUNNER VPC CONNECTOR
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "apprunner_connector" {
  count       = var.create_apprunner_security_group ? 1 : 0
  name        = "${var.aws_project}-apprunner-connector-sg"
  description = "Security group for App Runner VPC connector"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.aws_project}-AppRunnerConnectorSG"
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# SECURITY GROUP FOR RDS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "rds" {
  count       = var.create_rds_security_group ? 1 : 0
  name        = "${var.aws_project}-rds-sg"
  description = "Security group for RDS instances"
  vpc_id      = aws_vpc.main.id

  # Allow inbound traffic from App Runner VPC connector
  dynamic "ingress" {
    for_each = var.create_apprunner_security_group ? [1] : []
    content {
      from_port       = var.rds_port
      to_port         = var.rds_port
      protocol        = "tcp"
      security_groups = [aws_security_group.apprunner_connector[0].id]
      description     = "Allow database traffic from App Runner"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.aws_project}-RdsSG"
  })
}

# ---------------------------------------------------------------------------------------------------------------------
# NOTE: APP RUNNER CONNECTIVITY
# ---------------------------------------------------------------------------------------------------------------------
# This network configuration supports App Runner services with the following characteristics:
# 1. App Runner services can connect to RDS instances in private subnets via VPC connector
# 2. App Runner services are publicly accessible from the internet
# 3. App Runner applications can access external internet resources via NAT Gateway
#
# To use this network with App Runner:
# - Deploy RDS in private subnets with the rds security group
# - Configure App Runner with VPC connector using private subnets and apprunner_connector security group
# ---------------------------------------------------------------------------------------------------------------------
