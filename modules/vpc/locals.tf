# -----------------------------------------------------------------------------
# Local Values for VPC Module
# -----------------------------------------------------------------------------

locals {
  # Common tags merged with module-specific tags
  module_tags = merge(
    var.common_tags,
    {
      Module = "vpc"
    }
  )

  # Availability zones configuration
  availability_zones = length(var.availability_zones) > 0 ? var.availability_zones : data.aws_availability_zones.available.names

  # Maximum number of AZs to use (limit to 3 for cost optimization)
  max_azs = min(length(local.availability_zones), 3)

  # Selected availability zones
  selected_azs = slice(local.availability_zones, 0, local.max_azs)

  # Calculate subnet CIDR blocks automatically if not provided
  subnet_newbits = 8 # /16 -> /24 subnets

  # Public subnet configurations
  public_subnets_calculated = [
    for i, az in local.selected_azs : {
      cidr_block        = cidrsubnet(var.cidr_block, local.subnet_newbits, i + 1)
      availability_zone = az
    }
  ]

  # Private subnet configurations  
  private_subnets_calculated = [
    for i, az in local.selected_azs : {
      cidr_block        = cidrsubnet(var.cidr_block, local.subnet_newbits, i + 10)
      availability_zone = az
    }
  ]

  # Database subnet configurations
  database_subnets_calculated = [
    for i, az in local.selected_azs : {
      cidr_block        = cidrsubnet(var.cidr_block, local.subnet_newbits, i + 20)
      availability_zone = az
    }
  ]

  # Final subnet configurations (use provided or calculated)
  public_subnets = length(var.public_subnets) > 0 ? var.public_subnets : local.public_subnets_calculated

  private_subnets = length(var.private_subnets) > 0 ? var.private_subnets : (
    var.enable_nat_gateway ? local.private_subnets_calculated : []
  )

  # NAT Gateway configuration
  nat_gateway_count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(local.private_subnets)) : 0

  # Route table count for private subnets
  private_route_table_count = length(local.private_subnets)
}
