# -----------------------------------------------------------------------------
# Variable Definitions for EC2 Module
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
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Instance Configuration
# -----------------------------------------------------------------------------

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count >= 0 && var.instance_count <= 20
    error_message = "Instance count must be between 0 and 20."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^[a-z][0-9][a-z]*\\.[a-z0-9]+$", var.instance_type))
    error_message = "Instance type must be a valid EC2 instance type (e.g., t3.micro, m5.large)."
  }
}

variable "ami_id" {
  description = "AMI ID to use for instances. If null, will use latest Amazon Linux 2"
  type        = string
  default     = null
}

variable "key_name" {
  description = "Name of the AWS key pair to use for SSH access"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "subnet_ids" {
  description = "List of subnet IDs where instances will be placed"
  type        = list(string)
  default     = []
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to assign to instances"
  type        = list(string)
  default     = []
}

variable "associate_public_ip_address" {
  description = "Associate a public IP address with instances"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Storage Configuration
# -----------------------------------------------------------------------------

variable "root_block_device" {
  description = "Root block device configuration"
  type = object({
    volume_type           = optional(string, "gp3")
    volume_size           = optional(number, 20)
    iops                  = optional(number)
    throughput            = optional(number)
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string)
    delete_on_termination = optional(bool, true)
  })
  default = {}
}

variable "ebs_block_devices" {
  description = "Additional EBS block devices to attach"
  type = map(object({
    device_name           = string
    volume_type           = optional(string, "gp3")
    volume_size           = optional(number, 20)
    iops                  = optional(number)
    throughput            = optional(number)
    encrypted             = optional(bool, true)
    kms_key_id            = optional(string)
    delete_on_termination = optional(bool, true)
    snapshot_id           = optional(string)
  }))
  default = {}
}

variable "ebs_optimized" {
  description = "Enable EBS optimization"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# IAM Configuration
# -----------------------------------------------------------------------------

variable "create_iam_instance_profile" {
  description = "Create an IAM instance profile for the instances"
  type        = bool
  default     = false
}

variable "iam_instance_profile" {
  description = "Name of existing IAM instance profile to use"
  type        = string
  default     = null
}

variable "iam_role_policies" {
  description = "List of IAM policy ARNs to attach to the instance role"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Enhanced Security and Monitoring Variables
# -----------------------------------------------------------------------------

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring for instances"
  type        = bool
  default     = true
}

variable "enable_ssm_managed" {
  description = "Enable AWS Systems Manager for instances"
  type        = bool
  default     = true
}

variable "enable_backup" {
  description = "Enable AWS Backup for disaster recovery"
  type        = bool
  default     = true
}

variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance"
  type        = bool
  default     = true
}

variable "user_data_replace_on_change" {
  description = "Triggers a destroy and recreate when set to true and user_data is changed"
  type        = bool
  default     = false
}

variable "cpu_credits" {
  description = "Credit option for CPU usage on burstable performance instances"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "unlimited"], var.cpu_credits)
    error_message = "CPU credits must be either 'standard' or 'unlimited'."
  }
}

variable "create_eip" {
  description = "Create Elastic IP addresses for instances"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# CloudWatch Monitoring Variables
# -----------------------------------------------------------------------------

variable "cpu_alarm_threshold" {
  description = "CPU utilization threshold for CloudWatch alarms"
  type        = number
  default     = 80

  validation {
    condition     = var.cpu_alarm_threshold >= 0 && var.cpu_alarm_threshold <= 100
    error_message = "CPU alarm threshold must be between 0 and 100."
  }
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm state changes"
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention must be a valid CloudWatch log retention period."
  }
}

variable "cloudwatch_logs_kms_key_arn" {
  description = "ARN of KMS key for CloudWatch logs encryption"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Backup and Disaster Recovery Variables
# -----------------------------------------------------------------------------

variable "backup_schedule" {
  description = "Cron expression for backup schedule"
  type        = string
  default     = "cron(0 2 ? * * *)" # Daily at 2 AM
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 35
    error_message = "Backup retention must be between 1 and 35 days."
  }
}

variable "backup_vault_kms_key_arn" {
  description = "ARN of KMS key for backup vault encryption"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Instance Behavior Configuration
# -----------------------------------------------------------------------------

variable "user_data" {
  description = "User data script to run on instance startup"
  type        = string
  default     = null
}

variable "disable_api_termination" {
  description = "Enable termination protection"
  type        = bool
  default     = false
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance"
  type        = string
  default     = "stop"

  validation {
    condition     = contains(["stop", "terminate"], var.instance_initiated_shutdown_behavior)
    error_message = "Instance shutdown behavior must be either 'stop' or 'terminate'."
  }
}

variable "monitoring" {
  description = "Enable detailed monitoring (deprecated, use enable_detailed_monitoring)"
  type        = bool
  default     = false
}

variable "placement_tenancy" {
  description = "Tenancy of the instance"
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated", "host"], var.placement_tenancy)
    error_message = "Placement tenancy must be one of: default, dedicated, host."
  }
}
