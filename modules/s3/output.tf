# -----------------------------------------------------------------------------
# S3 Module Outputs - Enhanced for Monitoring and Integration
# -----------------------------------------------------------------------------

output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket_regional_domain_name
}

output "bucket_hosted_zone_id" {
  description = "Hosted zone ID of the S3 bucket"
  value       = aws_s3_bucket.main.hosted_zone_id
}

output "bucket_region" {
  description = "Region of the S3 bucket"
  value       = aws_s3_bucket.main.region
}

# -----------------------------------------------------------------------------
# Security and Configuration Outputs
# -----------------------------------------------------------------------------

output "versioning_enabled" {
  description = "Whether versioning is enabled on the bucket"
  value       = aws_s3_bucket_versioning.main.versioning_configuration[0].status == "Enabled"
}

output "encryption_enabled" {
  description = "Whether server-side encryption is enabled"
  value       = length(aws_s3_bucket_server_side_encryption_configuration.main.rule) > 0
}

output "public_access_blocked" {
  description = "Whether all public access is blocked"
  value = (
    aws_s3_bucket_public_access_block.main.block_public_acls &&
    aws_s3_bucket_public_access_block.main.block_public_policy &&
    aws_s3_bucket_public_access_block.main.ignore_public_acls &&
    aws_s3_bucket_public_access_block.main.restrict_public_buckets
  )
}

# -----------------------------------------------------------------------------
# Disaster Recovery Outputs
# -----------------------------------------------------------------------------

output "replication_enabled" {
  description = "Whether cross-region replication is enabled"
  value       = var.replication_configuration != null
}

output "replication_role_arn" {
  description = "ARN of the replication IAM role"
  value       = var.replication_configuration != null ? aws_iam_role.replication[0].arn : null
}

# -----------------------------------------------------------------------------
# Cost Optimization Outputs
# -----------------------------------------------------------------------------

output "lifecycle_rules_count" {
  description = "Number of lifecycle rules configured"
  value       = length(var.lifecycle_configuration)
}

output "intelligent_tiering_enabled" {
  description = "Whether intelligent tiering is enabled"
  value       = var.intelligent_tiering_configuration != null
}

# -----------------------------------------------------------------------------
# Website and Application Outputs
# -----------------------------------------------------------------------------

output "website_endpoint" {
  description = "Website endpoint (if website hosting is enabled)"
  value       = var.website_configuration != null ? aws_s3_bucket_website_configuration.main[0].website_endpoint : null
}

output "website_domain" {
  description = "Website domain (if website hosting is enabled)"
  value       = var.website_configuration != null ? aws_s3_bucket_website_configuration.main[0].website_domain : null
}

# -----------------------------------------------------------------------------
# Monitoring and Compliance Outputs
# -----------------------------------------------------------------------------

output "notification_configured" {
  description = "Whether bucket notifications are configured"
  value       = var.notification_configuration != null
}

output "logging_enabled" {
  description = "Whether access logging is enabled"
  value       = var.logging_configuration != null
}

output "object_lock_enabled" {
  description = "Whether object lock is enabled"
  value       = var.object_lock_configuration != null
}

output "cors_configured" {
  description = "Whether CORS is configured"
  value       = var.cors_configuration != null
}

# -----------------------------------------------------------------------------
# Data Classification and Compliance
# -----------------------------------------------------------------------------

output "data_classification" {
  description = "Data classification level of the bucket"
  value       = var.data_classification
}

output "compliance_features" {
  description = "Summary of compliance features enabled"
  value = {
    versioning_enabled     = aws_s3_bucket_versioning.main.versioning_configuration[0].status == "Enabled"
    encryption_enabled     = length(aws_s3_bucket_server_side_encryption_configuration.main.rule) > 0
    public_access_blocked  = aws_s3_bucket_public_access_block.main.block_public_acls
    replication_enabled    = var.replication_configuration != null
    object_lock_enabled    = var.object_lock_configuration != null
    lifecycle_rules_count  = length(var.lifecycle_configuration)
    access_logging_enabled = var.logging_configuration != null
  }
}
