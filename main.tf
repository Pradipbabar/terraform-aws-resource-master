# -----------------------------------------------------------------------------
# VPC Module
# -----------------------------------------------------------------------------

module "vpc" {
  count  = var.create_vpc ? 1 : 0
  source = "./modules/vpc"

  name_prefix = local.name_prefix
  environment = var.environment
  common_tags = local.common_tags

  cidr_block           = local.vpc_config.cidr_block
  enable_dns_hostnames = local.vpc_config.enable_dns_hostnames
  enable_dns_support   = local.vpc_config.enable_dns_support

  public_subnets  = local.vpc_config.public_subnets
  private_subnets = local.vpc_config.private_subnets

  enable_nat_gateway = local.vpc_config.enable_nat_gateway
  single_nat_gateway = local.vpc_config.single_nat_gateway
  enable_vpn_gateway = local.vpc_config.enable_vpn_gateway

  availability_zones = local.azs
}

# -----------------------------------------------------------------------------
# EC2 Module
# -----------------------------------------------------------------------------

module "ec2" {
  count  = var.create_ec2 ? 1 : 0
  source = "./modules/ec2"

  name_prefix = local.name_prefix
  environment = var.environment
  common_tags = local.common_tags

  instance_count = var.ec2_config.instance_count
  instance_type  = var.ec2_config.instance_type

  ami_id   = var.ec2_config.ami_id != null ? var.ec2_config.ami_id : data.aws_ami.amazon_linux[0].id
  key_name = var.ec2_config.key_name

  # Use VPC subnet if VPC module is created, otherwise use provided subnet_id
  subnet_ids = var.ec2_config.subnet_id != null ? [var.ec2_config.subnet_id] : (
    var.create_vpc ? module.vpc[0].public_subnet_ids : []
  )

  vpc_security_group_ids      = var.ec2_config.vpc_security_group_ids
  associate_public_ip_address = var.ec2_config.associate_public_ip_address

  root_block_device = var.ec2_config.root_block_device
  ebs_block_devices = {
    for i, device in var.ec2_config.ebs_block_devices :
    device.device_name => device
  }

  user_data                            = var.ec2_config.user_data
  disable_api_termination              = var.ec2_config.disable_api_termination
  instance_initiated_shutdown_behavior = var.ec2_config.instance_initiated_shutdown_behavior
  monitoring                           = var.ec2_config.monitoring

  depends_on = [module.vpc]
}

# -----------------------------------------------------------------------------
# RDS Module
# -----------------------------------------------------------------------------

module "rds" {
  count  = var.create_rds ? 1 : 0
  source = "./modules/rds"

  name_prefix = local.name_prefix
  environment = var.environment
  common_tags = local.common_tags

  identifier     = local.rds_identifier
  engine         = var.rds_config.engine
  engine_version = var.rds_config.engine_version
  instance_class = var.rds_config.instance_class

  allocated_storage     = var.rds_config.allocated_storage
  max_allocated_storage = var.rds_config.max_allocated_storage
  storage_type          = var.rds_config.storage_type
  storage_encrypted     = var.rds_config.storage_encrypted

  database_name = var.rds_config.database_name
  username      = var.rds_config.username
  password      = var.rds_config.password != null ? var.rds_config.password : random_password.rds_password[0].result

  # Use VPC subnets if VPC module is created
  vpc_security_group_ids = var.rds_config.vpc_security_group_ids
  db_subnet_group_name = var.rds_config.db_subnet_group_name != null ? var.rds_config.db_subnet_group_name : (
    var.create_vpc ? module.vpc[0].database_subnet_group_name : null
  )

  backup_retention_period = var.rds_config.backup_retention_period
  backup_window           = var.rds_config.backup_window
  maintenance_window      = var.rds_config.maintenance_window

  skip_final_snapshot       = var.rds_config.skip_final_snapshot
  final_snapshot_identifier = var.rds_config.final_snapshot_identifier
  deletion_protection       = var.rds_config.deletion_protection

  monitoring_interval = var.rds_config.monitoring_interval
  multi_az            = var.rds_config.multi_az
  publicly_accessible = var.rds_config.publicly_accessible

  depends_on = [module.vpc]
}

# -----------------------------------------------------------------------------
# S3 Module
# -----------------------------------------------------------------------------

module "s3" {
  count  = var.create_s3 ? 1 : 0
  source = "./modules/s3"

  name_prefix = local.name_prefix
  environment = var.environment
  common_tags = local.common_tags

  bucket_name   = local.s3_bucket_name
  force_destroy = var.s3_config.force_destroy

  versioning                           = var.s3_config.versioning
  server_side_encryption_configuration = var.s3_config.server_side_encryption_configuration
  public_access_block                  = var.s3_config.public_access_block
  lifecycle_configuration              = var.s3_config.lifecycle_configuration
  notification_configuration           = var.s3_config.notification_configuration
}

# -----------------------------------------------------------------------------
# CloudWatch Module
# -----------------------------------------------------------------------------

module "cloudwatch" {
  count  = var.create_cloudwatch ? 1 : 0
  source = "./modules/cloudwatch"

  name_prefix = local.name_prefix
  environment = var.environment
  common_tags = local.common_tags
}

# -----------------------------------------------------------------------------
# DynamoDB Module
# -----------------------------------------------------------------------------

module "dynamodb" {
  count  = var.create_dynamodb ? 1 : 0
  source = "./modules/dynamodb"

  name_prefix = local.name_prefix
  environment = var.environment
  common_tags = local.common_tags
}

# -----------------------------------------------------------------------------
# IAM Module
# -----------------------------------------------------------------------------

module "iam" {
  count  = var.create_iam ? 1 : 0
  source = "./modules/iam"

  name_prefix = local.name_prefix
  environment = var.environment
  common_tags = local.common_tags
}

# -----------------------------------------------------------------------------
# SNS Module
# -----------------------------------------------------------------------------

module "sns" {
  count  = var.create_sns ? 1 : 0
  source = "./modules/sns"

  name_prefix = local.name_prefix
  environment = var.environment
  common_tags = local.common_tags
}