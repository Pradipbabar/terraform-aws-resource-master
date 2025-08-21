# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    local.module_tags,
    {
      Name = "${var.name_prefix}-vpc"
    }
  )
}

# -----------------------------------------------------------------------------
# Internet Gateway
# -----------------------------------------------------------------------------

resource "aws_internet_gateway" "main" {
  count = var.enable_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(
    local.module_tags,
    {
      Name = "${var.name_prefix}-igw"
    }
  )
}

# -----------------------------------------------------------------------------
# Elastic IPs for NAT Gateways
# -----------------------------------------------------------------------------

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  domain = "vpc"

  depends_on = [aws_internet_gateway.main]

  tags = merge(
    local.module_tags,
    {
      Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
    }
  )
}

# -----------------------------------------------------------------------------
# Public Subnets
# -----------------------------------------------------------------------------

resource "aws_subnet" "public" {
  count = length(local.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.public_subnets[count.index].cidr_block
  availability_zone       = local.public_subnets[count.index].availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    local.module_tags,
    {
      Name = "${var.name_prefix}-public-subnet-${count.index + 1}"
      Type = "public"
    }
  )
}

# -----------------------------------------------------------------------------
# Private Subnets
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Private Subnets - Enhanced with Route Table Logic
# -----------------------------------------------------------------------------

resource "aws_subnet" "private" {
  count = length(local.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnets[count.index].cidr_block
  availability_zone = local.private_subnets[count.index].availability_zone

  tags = merge(
    local.module_tags,
    {
      Name = "${var.name_prefix}-private-subnet-${count.index + 1}"
      Type = "private"
      Tier = "application"
    }
  )
}

# -----------------------------------------------------------------------------
# Database Subnets
# -----------------------------------------------------------------------------

resource "aws_subnet" "database" {
  count = length(local.database_subnets_calculated)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.database_subnets_calculated[count.index].cidr_block
  availability_zone = local.database_subnets_calculated[count.index].availability_zone

  tags = merge(
    local.module_tags,
    {
      Name = "${var.name_prefix}-database-subnet-${count.index + 1}"
      Type = "database"
    }
  )
}

# -----------------------------------------------------------------------------
# Database Subnet Group
# -----------------------------------------------------------------------------

resource "aws_db_subnet_group" "main" {
  count = length(local.database_subnets_calculated) > 0 ? 1 : 0

  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    local.module_tags,
    {
      Name = "${var.name_prefix}-db-subnet-group"
    }
  )
}

# -----------------------------------------------------------------------------
# NAT Gateways
# -----------------------------------------------------------------------------

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index % length(aws_subnet.public)].id

  depends_on = [aws_internet_gateway.main]

  tags = merge(
    local.module_tags,
    {
      Name = "${var.name_prefix}-nat-gateway-${count.index + 1}"
    }
  )
}

# -----------------------------------------------------------------------------
# Route Tables
# -----------------------------------------------------------------------------

# Public Route Table
resource "aws_route_table" "public" {
  count = length(aws_subnet.public) > 0 ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(
    local.module_tags,
    {
      Name = "${var.name_prefix}-public-rt"
      Type = "public"
    }
  )
}

# Private Route Tables
resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : (length(aws_subnet.private) > 0 ? 1 : 0)

  vpc_id = aws_vpc.main.id

  tags = merge(
    local.module_tags,
    {
      Name = "${var.name_prefix}-private-rt-${count.index + 1}"
      Type = "private"
    }
  )
}

# Database Route Tables
resource "aws_route_table" "database" {
  count = length(aws_subnet.database) > 0 ? 1 : 0

  vpc_id = aws_vpc.main.id

  tags = merge(
    local.module_tags,
    {
      Name = "${var.name_prefix}-database-rt"
      Type = "database"
    }
  )
}

# -----------------------------------------------------------------------------
# Routes
# -----------------------------------------------------------------------------

# Public Routes
resource "aws_route" "public_internet_gateway" {
  count = var.enable_internet_gateway && length(aws_route_table.public) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main[0].id

  timeouts {
    create = "5m"
  }
}

# Private Routes to NAT Gateway
resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id

  timeouts {
    create = "5m"
  }
}

# -----------------------------------------------------------------------------
# Route Table Associations
# -----------------------------------------------------------------------------

# Public Subnet Associations
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# Private Subnet Associations
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id = aws_subnet.private[count.index].id
  route_table_id = var.enable_nat_gateway ? (
    aws_route_table.private[count.index % local.nat_gateway_count].id
  ) : aws_route_table.private[0].id
}

# Database Subnet Associations
resource "aws_route_table_association" "database" {
  count = length(aws_subnet.database)

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database[0].id
}

# -----------------------------------------------------------------------------
# VPN Gateway
# -----------------------------------------------------------------------------

resource "aws_vpn_gateway" "main" {
  count = var.enable_vpn_gateway ? 1 : 0

  vpc_id          = aws_vpc.main.id
  amazon_side_asn = var.vpn_gateway_amazon_side_asn

  tags = merge(
    local.module_tags,
    {
      Name = "${var.name_prefix}-vpn-gateway"
    }
  )
}

resource "aws_vpn_gateway_attachment" "main" {
  count = var.enable_vpn_gateway ? 1 : 0

  vpc_id         = aws_vpc.main.id
  vpn_gateway_id = aws_vpn_gateway.main[0].id
}

# -----------------------------------------------------------------------------
# Default Security Group Rules
# -----------------------------------------------------------------------------

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  # Restrict default security group to deny all traffic by default
  ingress = []
  egress  = []

  tags = merge(
    local.module_tags,
    {
      Name = "${var.name_prefix}-default-sg"
    }
  )
}
