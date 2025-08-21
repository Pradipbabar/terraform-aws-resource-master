# -----------------------------------------------------------------------------
# Variable Definitions for IAM Module
# -----------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.name_prefix))
    error_message = "Name prefix must start with a letter and contain only alphanumeric characters and hyphens."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Role Configuration
# -----------------------------------------------------------------------------

variable "create_role" {
  description = "Whether to create the IAM role"
  type        = bool
  default     = true
}

variable "role_description" {
  description = "Description of the IAM role"
  type        = string
  default     = "IAM role created by Terraform"
}

variable "role_purpose" {
  description = "Purpose of the IAM role for tagging"
  type        = string
  default     = "General"
}

variable "security_tier" {
  description = "Security tier classification (Low, Medium, High)"
  type        = string
  default     = "Medium"

  validation {
    condition     = contains(["Low", "Medium", "High"], var.security_tier)
    error_message = "Security tier must be one of: Low, Medium, High."
  }
}

variable "custom_assume_role_policy" {
  description = "Custom assume role policy JSON. If null, uses default policy"
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Maximum session duration for the role (in seconds)"
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "Max session duration must be between 3600 (1 hour) and 43200 (12 hours) seconds."
  }
}

variable "role_path" {
  description = "Path for the IAM role"
  type        = string
  default     = "/"
}

variable "permissions_boundary_arn" {
  description = "ARN of the permissions boundary for the role"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Cross-Account Role Configuration
# -----------------------------------------------------------------------------

variable "create_cross_account_role" {
  description = "Whether to create a cross-account IAM role"
  type        = bool
  default     = false
}

variable "trusted_account_arns" {
  description = "List of trusted AWS account ARNs for cross-account access"
  type        = list(string)
  default     = []
}

variable "require_external_id" {
  description = "Whether to require external ID for cross-account access"
  type        = bool
  default     = true
}

variable "external_id" {
  description = "External ID for cross-account access"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Trusted Principals Configuration
# -----------------------------------------------------------------------------

variable "trusted_services" {
  description = "List of AWS services that can assume the role"
  type        = list(string)
  default     = ["ec2.amazonaws.com"]
}

variable "trusted_principals" {
  description = "List of principal types (Service, AWS, User, etc.)"
  type        = list(string)
  default     = ["Service"]
}

variable "require_mfa" {
  description = "Whether to require MFA for role assumption"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Policy Configuration
# -----------------------------------------------------------------------------

variable "aws_managed_policies" {
  description = "List of AWS managed policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "cross_account_managed_policies" {
  description = "List of AWS managed policy ARNs to attach to the cross-account role"
  type        = list(string)
  default     = []
}

variable "custom_policies" {
  description = "List of custom policies to create and attach"
  type = list(object({
    name        = string
    description = string
    policy      = string
  }))
  default = []
}

variable "policy_path" {
  description = "Path for IAM policies"
  type        = string
  default     = "/"
}

# -----------------------------------------------------------------------------
# Enhanced Security Features
# -----------------------------------------------------------------------------

variable "enable_cloudwatch_logs_access" {
  description = "Enable CloudWatch Logs access policy"
  type        = bool
  default     = false
}

variable "enable_s3_backup_access" {
  description = "Enable S3 backup access policy"
  type        = bool
  default     = false
}

variable "s3_backup_bucket_arns" {
  description = "List of S3 bucket ARNs for backup access"
  type        = list(string)
  default     = []
}

variable "s3_backup_kms_key_arns" {
  description = "List of KMS key ARNs for S3 backup encryption"
  type        = list(string)
  default     = []
}

variable "enable_security_audit" {
  description = "Enable security audit policy"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Instance Profile Configuration
# -----------------------------------------------------------------------------

variable "create_instance_profile" {
  description = "Whether to create an instance profile"
  type        = bool
  default     = true
}

variable "instance_profile_path" {
  description = "Path for the instance profile"
  type        = string
  default     = "/"
}

# -----------------------------------------------------------------------------
# User Management
# -----------------------------------------------------------------------------

variable "iam_users" {
  description = "List of IAM users to create"
  type = list(object({
    name          = string
    purpose       = optional(string, "General")
    force_destroy = optional(bool, false)
    policy_arns   = optional(list(string), [])
  }))
  default = []
}

variable "user_path" {
  description = "Path for IAM users"
  type        = string
  default     = "/"
}

variable "create_access_keys" {
  description = "List of user indices for which to create access keys"
  type        = list(number)
  default     = []
}

variable "pgp_key" {
  description = "PGP key for encrypting access keys"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Group Management
# -----------------------------------------------------------------------------

variable "iam_groups" {
  description = "List of IAM groups to create"
  type = list(object({
    name        = string
    users       = optional(list(string), [])
    policy_arns = optional(list(string), [])
  }))
  default = []
}

variable "group_path" {
  description = "Path for IAM groups"
  type        = string
  default     = "/"
}

# -----------------------------------------------------------------------------
# Password Policy Configuration
# -----------------------------------------------------------------------------

variable "set_password_policy" {
  description = "Whether to set account password policy"
  type        = bool
  default     = false
}

variable "password_policy" {
  description = "Password policy configuration"
  type = object({
    minimum_length         = optional(number, 14)
    require_lowercase      = optional(bool, true)
    require_numbers        = optional(bool, true)
    require_uppercase      = optional(bool, true)
    require_symbols        = optional(bool, true)
    allow_users_to_change  = optional(bool, true)
    hard_expiry            = optional(bool, false)
    max_age_days           = optional(number, 90)
    reuse_prevention_count = optional(number, 24)
  })
  default = {}
}
