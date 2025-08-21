# -----------------------------------------------------------------------------
# VPC Module Outputs
# -----------------------------------------------------------------------------

output "vpc" {
  description = "VPC module outputs"
  value = var.create_vpc ? {
    vpc_id                     = module.vpc[0].vpc_id
    vpc_arn                    = module.vpc[0].vpc_arn
    vpc_cidr_block             = module.vpc[0].vpc_cidr_block
    public_subnet_ids          = module.vpc[0].public_subnet_ids
    private_subnet_ids         = module.vpc[0].private_subnet_ids
    database_subnet_ids        = module.vpc[0].database_subnet_ids
    database_subnet_group_name = module.vpc[0].database_subnet_group_name
    internet_gateway_id        = module.vpc[0].internet_gateway_id
    nat_gateway_ids            = module.vpc[0].nat_gateway_ids
    public_route_table_ids     = module.vpc[0].public_route_table_ids
    private_route_table_ids    = module.vpc[0].private_route_table_ids
  } : null
}

output "vpc_id" {
  description = "ID of the VPC (for backward compatibility)"
  value       = var.create_vpc ? module.vpc[0].vpc_id : null
}

# -----------------------------------------------------------------------------
# EC2 Module Outputs
# -----------------------------------------------------------------------------

output "ec2" {
  description = "EC2 module outputs"
  value = var.create_ec2 ? {
    instance_ids              = module.ec2[0].instance_ids
    instance_arns             = module.ec2[0].instance_arns
    instance_public_ips       = module.ec2[0].instance_public_ips
    instance_private_ips      = module.ec2[0].instance_private_ips
    instance_public_dns       = module.ec2[0].instance_public_dns
    instance_private_dns      = module.ec2[0].instance_private_dns
    iam_role_arn              = module.ec2[0].iam_role_arn
    iam_instance_profile_name = module.ec2[0].iam_instance_profile_name
  } : null
}

output "ec2_id" {
  description = "First EC2 instance ID (for backward compatibility)"
  value       = var.create_ec2 && length(module.ec2) > 0 ? (length(module.ec2[0].instance_ids) > 0 ? module.ec2[0].instance_ids[0] : null) : null
}

# -----------------------------------------------------------------------------
# RDS Module Outputs
# -----------------------------------------------------------------------------

output "rds" {
  description = "RDS module outputs"
  value = var.create_rds ? {
    db_instance_id       = module.rds[0].db_instance_id
    db_instance_arn      = module.rds[0].db_instance_arn
    db_instance_endpoint = module.rds[0].db_instance_endpoint
    db_instance_port     = module.rds[0].db_instance_port
    db_subnet_group_name = module.rds[0].db_subnet_group_name
  } : null
}

output "rds_outputs" {
  description = "RDS endpoint (for backward compatibility)"
  value       = var.create_rds ? module.rds[0].db_instance_endpoint : null
}

# -----------------------------------------------------------------------------
# S3 Module Outputs
# -----------------------------------------------------------------------------

output "s3" {
  description = "S3 module outputs"
  value = var.create_s3 ? {
    bucket_id                   = module.s3[0].bucket_id
    bucket_arn                  = module.s3[0].bucket_arn
    bucket_domain_name          = module.s3[0].bucket_domain_name
    bucket_regional_domain_name = module.s3[0].bucket_regional_domain_name
    bucket_hosted_zone_id       = module.s3[0].bucket_hosted_zone_id
  } : null
}

output "s3_outputs" {
  description = "S3 bucket name (for backward compatibility)"
  value       = var.create_s3 ? module.s3[0].bucket_id : null
}

# -----------------------------------------------------------------------------
# Additional Module Outputs
# -----------------------------------------------------------------------------

output "cloudwatch" {
  description = "CloudWatch module outputs"
  value = var.create_cloudwatch ? {
    log_group_name = module.cloudwatch[0].log_group_name
    log_group_arn  = module.cloudwatch[0].log_group_arn
  } : null
}

output "dynamodb" {
  description = "DynamoDB module outputs"
  value = var.create_dynamodb ? {
    table_name = module.dynamodb[0].table_name
    table_arn  = module.dynamodb[0].table_arn
  } : null
}

output "iam" {
  description = "IAM module outputs"
  value = var.create_iam ? {
    role_arn  = module.iam[0].role_arn
    role_name = module.iam[0].role_name
  } : null
}

output "sns" {
  description = "SNS module outputs"
  value = var.create_sns ? {
    topic_arn  = module.sns[0].topic_arn
    topic_name = module.sns[0].topic_name
  } : null
}
