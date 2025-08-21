# -----------------------------------------------------------------------------
# Output Values for IAM Module
# -----------------------------------------------------------------------------

# Main Role Outputs
output "role_arn" {
  description = "ARN of the IAM role"
  value       = var.create_role ? aws_iam_role.main[0].arn : null
}

output "role_name" {
  description = "Name of the IAM role"
  value       = var.create_role ? aws_iam_role.main[0].name : null
}

output "role_id" {
  description = "ID of the IAM role"
  value       = var.create_role ? aws_iam_role.main[0].id : null
}

output "role_unique_id" {
  description = "Unique ID of the IAM role"
  value       = var.create_role ? aws_iam_role.main[0].unique_id : null
}

# Cross-Account Role Outputs
output "cross_account_role_arn" {
  description = "ARN of the cross-account IAM role"
  value       = var.create_cross_account_role ? aws_iam_role.cross_account[0].arn : null
}

output "cross_account_role_name" {
  description = "Name of the cross-account IAM role"
  value       = var.create_cross_account_role ? aws_iam_role.cross_account[0].name : null
}

# Instance Profile Outputs
output "instance_profile_arn" {
  description = "ARN of the instance profile"
  value       = var.create_role && var.create_instance_profile ? aws_iam_instance_profile.main[0].arn : null
}

output "instance_profile_name" {
  description = "Name of the instance profile"
  value       = var.create_role && var.create_instance_profile ? aws_iam_instance_profile.main[0].name : null
}

output "instance_profile_id" {
  description = "ID of the instance profile"
  value       = var.create_role && var.create_instance_profile ? aws_iam_instance_profile.main[0].id : null
}

# Policy Outputs
output "custom_policy_arns" {
  description = "ARNs of custom policies created"
  value       = aws_iam_policy.custom[*].arn
}

output "custom_policy_names" {
  description = "Names of custom policies created"
  value       = aws_iam_policy.custom[*].name
}

output "cloudwatch_logs_policy_arn" {
  description = "ARN of the CloudWatch logs policy"
  value       = var.enable_cloudwatch_logs_access ? aws_iam_policy.cloudwatch_logs[0].arn : null
}

output "s3_backup_policy_arn" {
  description = "ARN of the S3 backup policy"
  value       = var.enable_s3_backup_access ? aws_iam_policy.s3_backup[0].arn : null
}

output "security_audit_policy_arn" {
  description = "ARN of the security audit policy"
  value       = var.enable_security_audit ? aws_iam_policy.security_audit[0].arn : null
}

# User Outputs
output "user_names" {
  description = "Names of created IAM users"
  value       = aws_iam_user.users[*].name
}

output "user_arns" {
  description = "ARNs of created IAM users"
  value       = aws_iam_user.users[*].arn
}

output "user_unique_ids" {
  description = "Unique IDs of created IAM users"
  value       = aws_iam_user.users[*].unique_id
}

# Access Key Outputs (sensitive)
output "access_key_ids" {
  description = "Access key IDs for created users"
  value       = aws_iam_access_key.user_keys[*].id
  sensitive   = true
}

output "secret_access_keys" {
  description = "Secret access keys for created users (encrypted if PGP key provided)"
  value       = aws_iam_access_key.user_keys[*].secret
  sensitive   = true
}

output "encrypted_secret_access_keys" {
  description = "Encrypted secret access keys (if PGP key provided)"
  value       = aws_iam_access_key.user_keys[*].encrypted_secret
  sensitive   = true
}

# Group Outputs
output "group_names" {
  description = "Names of created IAM groups"
  value       = aws_iam_group.groups[*].name
}

output "group_arns" {
  description = "ARNs of created IAM groups"
  value       = aws_iam_group.groups[*].arn
}

output "group_unique_ids" {
  description = "Unique IDs of created IAM groups"
  value       = aws_iam_group.groups[*].unique_id
}

# Security and Configuration Outputs
output "role_configuration" {
  description = "Configuration summary of the main role"
  value = var.create_role ? {
    role_name              = aws_iam_role.main[0].name
    max_session_duration   = aws_iam_role.main[0].max_session_duration
    permissions_boundary   = aws_iam_role.main[0].permissions_boundary
    mfa_required           = var.require_mfa
    security_tier          = var.security_tier
    cloudwatch_logs_access = var.enable_cloudwatch_logs_access
    s3_backup_access       = var.enable_s3_backup_access
    security_audit_enabled = var.enable_security_audit
  } : null
}

output "security_features" {
  description = "Summary of enabled security features"
  value = {
    mfa_enforcement       = var.require_mfa
    cross_account_role    = var.create_cross_account_role
    external_id_required  = var.require_external_id
    password_policy_set   = var.set_password_policy
    permissions_boundary  = var.permissions_boundary_arn != null
    cloudwatch_monitoring = var.enable_cloudwatch_logs_access
    backup_access         = var.enable_s3_backup_access
    security_audit        = var.enable_security_audit
  }
}
