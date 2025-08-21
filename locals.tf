# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------

locals {
  # Common naming convention
  name_prefix = "${var.name_prefix}-${var.environment}"

  # Common tags that will be applied to all resources
  common_tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Module      = "aws-infrastructure"
      CreatedBy   = "Terraform"
      CreatedOn   = timestamp()
    }
  )

  # Availability zones - dynamically fetch if not provided
  azs = data.aws_availability_zones.available.names

  # VPC configuration with defaults
  vpc_config = var.create_vpc ? {
    cidr_block           = var.vpc_config.cidr_block
    enable_dns_hostnames = var.vpc_config.enable_dns_hostnames
    enable_dns_support   = var.vpc_config.enable_dns_support
    public_subnets       = var.vpc_config.public_subnets
    private_subnets      = var.vpc_config.private_subnets
    enable_nat_gateway   = var.vpc_config.enable_nat_gateway
    single_nat_gateway   = var.vpc_config.single_nat_gateway
    enable_vpn_gateway   = var.vpc_config.enable_vpn_gateway
  } : null

  # Generate unique bucket name if not provided
  s3_bucket_name = var.s3_config.bucket_name != null ? var.s3_config.bucket_name : "${local.name_prefix}-bucket-${random_id.bucket_suffix[0].hex}"

  # RDS identifier with fallback
  rds_identifier = var.rds_config.identifier != null ? var.rds_config.identifier : "${local.name_prefix}-db"
}
