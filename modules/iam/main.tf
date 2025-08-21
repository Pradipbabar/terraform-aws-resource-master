# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_partition" "current" {}

# -----------------------------------------------------------------------------
# IAM Roles with Enhanced Security
# -----------------------------------------------------------------------------

resource "aws_iam_role" "main" {
  count = var.create_role ? 1 : 0

  name                 = "${var.name_prefix}-role"
  description          = var.role_description
  assume_role_policy   = var.custom_assume_role_policy != null ? var.custom_assume_role_policy : local.default_assume_role_policy
  max_session_duration = var.max_session_duration
  path                 = var.role_path
  permissions_boundary = var.permissions_boundary_arn

  # Force MFA for human users
  dynamic "inline_policy" {
    for_each = var.require_mfa && contains(var.trusted_principals, "User") ? [1] : []
    content {
      name = "EnforceMFA"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "DenyAllExceptUsersWithMFA"
            Effect = "Deny"
            NotAction = [
              "iam:CreateVirtualMFADevice",
              "iam:EnableMFADevice",
              "iam:GetUser",
              "iam:ListMFADevices",
              "iam:ListVirtualMFADevices",
              "iam:ResyncMFADevice",
              "sts:GetSessionToken"
            ]
            Resource = "*"
            Condition = {
              BoolIfExists = {
                "aws:MultiFactorAuthPresent" = "false"
              }
            }
          }
        ]
      })
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name         = "${var.name_prefix}-role"
      Type         = "IAMRole"
      Environment  = var.environment
      CreatedBy    = "Terraform"
      Purpose      = var.role_purpose
      SecurityTier = var.security_tier
    }
  )
}

# Cross-account role for disaster recovery
resource "aws_iam_role" "cross_account" {
  count = var.create_cross_account_role ? 1 : 0

  name               = "${var.name_prefix}-cross-account-role"
  description        = "Cross-account role for disaster recovery and backup operations"
  assume_role_policy = local.cross_account_assume_role_policy
  path               = var.role_path

  tags = merge(
    var.common_tags,
    {
      Name         = "${var.name_prefix}-cross-account-role"
      Type         = "CrossAccountRole"
      Environment  = var.environment
      CreatedBy    = "Terraform"
      Purpose      = "DisasterRecovery"
      SecurityTier = "High"
    }
  )
}

# -----------------------------------------------------------------------------
# IAM Policies
# -----------------------------------------------------------------------------

# Custom managed policies
resource "aws_iam_policy" "custom" {
  count = length(var.custom_policies)

  name        = "${var.name_prefix}-${var.custom_policies[count.index].name}"
  description = var.custom_policies[count.index].description
  policy      = var.custom_policies[count.index].policy
  path        = var.policy_path

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-${var.custom_policies[count.index].name}"
      Type        = "IAMPolicy"
      Environment = var.environment
      CreatedBy   = "Terraform"
      PolicyType  = "Custom"
    }
  )
}

# CloudWatch Logs policy for enhanced monitoring
resource "aws_iam_policy" "cloudwatch_logs" {
  count = var.enable_cloudwatch_logs_access ? 1 : 0

  name        = "${var.name_prefix}-cloudwatch-logs-policy"
  description = "Policy for CloudWatch Logs access with enhanced monitoring"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutRetentionPolicy",
          "logs:TagLogGroup"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:/aws/${var.name_prefix}/*",
          "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:/aws/${var.name_prefix}/*:*"
        ]
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-cloudwatch-logs-policy"
      Type        = "IAMPolicy"
      Environment = var.environment
      CreatedBy   = "Terraform"
      PolicyType  = "CloudWatchLogs"
    }
  )
}

# S3 backup policy for disaster recovery
resource "aws_iam_policy" "s3_backup" {
  count = var.enable_s3_backup_access ? 1 : 0

  name        = "${var.name_prefix}-s3-backup-policy"
  description = "Policy for S3 backup operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:PutBucketVersioning",
          "s3:GetObjectVersion",
          "s3:DeleteObjectVersion"
        ]
        Resource = var.s3_backup_bucket_arns
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = var.s3_backup_kms_key_arns
        Condition = {
          StringEquals = {
            "kms:ViaService" = "s3.${data.aws_region.current.id}.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-s3-backup-policy"
      Type        = "IAMPolicy"
      Environment = var.environment
      CreatedBy   = "Terraform"
      PolicyType  = "S3Backup"
    }
  )
}

# Security audit policy
resource "aws_iam_policy" "security_audit" {
  count = var.enable_security_audit ? 1 : 0

  name        = "${var.name_prefix}-security-audit-policy"
  description = "Policy for security auditing and compliance monitoring"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListAttachedRolePolicies",
          "iam:ListRolePolicies",
          "iam:ListInstanceProfiles",
          "iam:ListRoles",
          "iam:GenerateCredentialReport",
          "iam:GetCredentialReport",
          "iam:GetAccountSummary",
          "cloudtrail:DescribeTrails",
          "cloudtrail:GetTrailStatus",
          "config:DescribeConfigRules",
          "config:DescribeConfigurationRecorders",
          "config:DescribeDeliveryChannels",
          "securityhub:GetFindings",
          "guardduty:GetFindings",
          "inspector:DescribeFindings"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-security-audit-policy"
      Type        = "IAMPolicy"
      Environment = var.environment
      CreatedBy   = "Terraform"
      PolicyType  = "SecurityAudit"
    }
  )
}

# -----------------------------------------------------------------------------
# Policy Attachments
# -----------------------------------------------------------------------------

# Attach AWS managed policies to the main role
resource "aws_iam_role_policy_attachment" "aws_managed" {
  count = var.create_role ? length(var.aws_managed_policies) : 0

  role       = aws_iam_role.main[0].name
  policy_arn = var.aws_managed_policies[count.index]
}

# Attach custom policies to the main role
resource "aws_iam_role_policy_attachment" "custom" {
  count = var.create_role ? length(aws_iam_policy.custom) : 0

  role       = aws_iam_role.main[0].name
  policy_arn = aws_iam_policy.custom[count.index].arn
}

# Attach CloudWatch logs policy
resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  count = var.create_role && var.enable_cloudwatch_logs_access ? 1 : 0

  role       = aws_iam_role.main[0].name
  policy_arn = aws_iam_policy.cloudwatch_logs[0].arn
}

# Attach S3 backup policy
resource "aws_iam_role_policy_attachment" "s3_backup" {
  count = var.create_role && var.enable_s3_backup_access ? 1 : 0

  role       = aws_iam_role.main[0].name
  policy_arn = aws_iam_policy.s3_backup[0].arn
}

# Attach security audit policy
resource "aws_iam_role_policy_attachment" "security_audit" {
  count = var.create_role && var.enable_security_audit ? 1 : 0

  role       = aws_iam_role.main[0].name
  policy_arn = aws_iam_policy.security_audit[0].arn
}

# Cross-account role policy attachments
resource "aws_iam_role_policy_attachment" "cross_account_managed" {
  count = var.create_cross_account_role ? length(var.cross_account_managed_policies) : 0

  role       = aws_iam_role.cross_account[0].name
  policy_arn = var.cross_account_managed_policies[count.index]
}

# -----------------------------------------------------------------------------
# IAM Instance Profile
# -----------------------------------------------------------------------------

resource "aws_iam_instance_profile" "main" {
  count = var.create_role && var.create_instance_profile ? 1 : 0

  name = "${var.name_prefix}-instance-profile"
  role = aws_iam_role.main[0].name
  path = var.instance_profile_path

  tags = merge(
    var.common_tags,
    {
      Name        = "${var.name_prefix}-instance-profile"
      Type        = "IAMInstanceProfile"
      Environment = var.environment
      CreatedBy   = "Terraform"
    }
  )
}

# -----------------------------------------------------------------------------
# IAM Users (Optional)
# -----------------------------------------------------------------------------

resource "aws_iam_user" "users" {
  count = length(var.iam_users)

  name          = var.iam_users[count.index].name
  path          = var.user_path
  force_destroy = var.iam_users[count.index].force_destroy

  tags = merge(
    var.common_tags,
    {
      Name        = var.iam_users[count.index].name
      Type        = "IAMUser"
      Environment = var.environment
      CreatedBy   = "Terraform"
      Purpose     = var.iam_users[count.index].purpose
    }
  )
}

# Attach policies to users
resource "aws_iam_user_policy_attachment" "user_policies" {
  count = length(local.user_policy_attachments)

  user       = aws_iam_user.users[local.user_policy_attachments[count.index].user_index].name
  policy_arn = local.user_policy_attachments[count.index].policy_arn
}

# -----------------------------------------------------------------------------
# IAM Groups (Optional)
# -----------------------------------------------------------------------------

resource "aws_iam_group" "groups" {
  count = length(var.iam_groups)

  name = var.iam_groups[count.index].name
  path = var.group_path
}

# Attach policies to groups
resource "aws_iam_group_policy_attachment" "group_policies" {
  count = length(local.group_policy_attachments)

  group      = aws_iam_group.groups[local.group_policy_attachments[count.index].group_index].name
  policy_arn = local.group_policy_attachments[count.index].policy_arn
}

# Add users to groups
resource "aws_iam_group_membership" "group_memberships" {
  count = length(var.iam_groups)

  name  = "${var.iam_groups[count.index].name}-membership"
  users = var.iam_groups[count.index].users
  group = aws_iam_group.groups[count.index].name
}

# -----------------------------------------------------------------------------
# Access Keys for Users (with caution)
# -----------------------------------------------------------------------------

resource "aws_iam_access_key" "user_keys" {
  count = length(var.create_access_keys) > 0 ? length(var.create_access_keys) : 0

  user = aws_iam_user.users[count.index].name

  # Store in encrypted form
  pgp_key = var.pgp_key
}

# -----------------------------------------------------------------------------
# Password policy for enhanced security
# -----------------------------------------------------------------------------

resource "aws_iam_account_password_policy" "strict" {
  count = var.set_password_policy ? 1 : 0

  minimum_password_length        = var.password_policy.minimum_length
  require_lowercase_characters   = var.password_policy.require_lowercase
  require_numbers                = var.password_policy.require_numbers
  require_uppercase_characters   = var.password_policy.require_uppercase
  require_symbols                = var.password_policy.require_symbols
  allow_users_to_change_password = var.password_policy.allow_users_to_change
  hard_expiry                    = var.password_policy.hard_expiry
  max_password_age               = var.password_policy.max_age_days
  password_reuse_prevention      = var.password_policy.reuse_prevention_count
}
