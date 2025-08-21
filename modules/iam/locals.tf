# -----------------------------------------------------------------------------
# Local Values for IAM Module
# -----------------------------------------------------------------------------

locals {
  # Common tags for all resources
  module_tags = merge(
    var.common_tags,
    {
      Module      = "iam"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )

  # Default assume role policy for EC2 service
  default_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = var.trusted_services
        }
      }
    ]
  })

  # Cross-account assume role policy
  cross_account_assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = var.trusted_account_arns
        }
        Condition = var.require_external_id ? {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        } : {}
      }
    ]
  })

  # Create user-policy attachment combinations
  user_policy_attachments = flatten([
    for user_idx, user in var.iam_users : [
      for policy_arn in user.policy_arns : {
        user_index = user_idx
        policy_arn = policy_arn
      }
    ]
  ])

  # Create group-policy attachment combinations
  group_policy_attachments = flatten([
    for group_idx, group in var.iam_groups : [
      for policy_arn in group.policy_arns : {
        group_index = group_idx
        policy_arn  = policy_arn
      }
    ]
  ])
}
