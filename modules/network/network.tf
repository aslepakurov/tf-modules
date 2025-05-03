data "aws_availability_zones" "available" {}

# ---------------------------------------------------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
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
# NAT GATEWAY (OPTIONAL)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : var.az_count) : 0
  domain = "vpc"
  tags = merge(var.tags, {
    Name = "${var.aws_project}-NatGateway-EIP-${count.index + 1}"
  })
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : var.az_count) : 0
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  tags = merge(var.tags, {
    Name = "${var.aws_project}-NatGateway-${count.index + 1}"
  })

  depends_on = [aws_internet_gateway.igw]
}

# ---------------------------------------------------------------------------------------------------------------------
# PRIVATE ROUTE TABLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_route_table" "private-route-table" {
  count  = var.single_nat_gateway ? 1 : var.az_count
  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = element(
        aws_nat_gateway.nat_gateway.*.id,
        var.single_nat_gateway ? 0 : count.index
      )
    }
  }

  tags = merge(var.tags, {
    Name = "${var.aws_project}-PrivateRouteTable${var.single_nat_gateway ? "" : "-${count.index + 1}"}"
  })
}

resource "aws_route_table_association" "private-route-association" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(
    aws_route_table.private-route-table.*.id,
    var.single_nat_gateway ? 0 : count.index
  )
}
