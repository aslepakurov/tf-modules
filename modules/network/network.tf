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

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, {
    Name = "${var.aws_project}-PublicRouteTable"
  })
}

resource "aws_route_table_association" "public-route-association" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public-route-table.id
}

# ---------------------------------------------------------------------------------------------------------------------
# NAT GATEWAY FOR PRIVATE SUBNET INTERNET ACCESS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : var.az_count) : 0
  domain = "vpc"
  tags = merge(var.tags, {
    Name = "${var.aws_project}-NAT-EIP-${count.index + 1}"
  })
}

resource "aws_nat_gateway" "nat" {
  count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : var.az_count) : 0
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

resource "aws_route_table" "private-route-table" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = element(aws_nat_gateway.nat.*.id, var.single_nat_gateway ? 0 : count.index)
    }
  }

  tags = merge(var.tags, {
    Name = "${var.aws_project}-PrivateRouteTable-${count.index + 1}"
  })
}

resource "aws_route_table_association" "private-route-association" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private-route-table.*.id, count.index)
}

# ---------------------------------------------------------------------------------------------------------------------
# VPC ENDPOINT FOR DYNAMODB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.private-route-table[*].id

  tags = merge(var.tags, {
    Name = "${var.aws_project}-DynamoDBEndpoint"
  })
}

resource "aws_vpc_endpoint" "cognito" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.aws_region}.cognito-idp"
  vpc_endpoint_type  = "Gateway"
  route_table_ids    = aws_route_table.private-route-table[*].id

  tags = merge(var.tags, {
    Name = "${var.aws_project}-CognitoEndpoint"
  })
}