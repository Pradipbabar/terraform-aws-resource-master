# -----------------------------------------------------------------------------
# Module Configuration Variables
# -----------------------------------------------------------------------------

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
  }
}

variable "name_prefix" {
  description = "Prefix to be used for resource naming"
  type        = string
  default     = "aws-resources"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.name_prefix))
    error_message = "Name prefix must contain only alphanumeric characters and hyphens."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

# -----------------------------------------------------------------------------
# VPC Module Variables
# -----------------------------------------------------------------------------

variable "create_vpc" {
  description = "Whether to create VPC resources"
  type        = bool
  default     = false
}

variable "vpc_config" {
  description = "Configuration for VPC module"
  type = object({
    cidr_block           = optional(string, "10.0.0.0/16")
    enable_dns_hostnames = optional(bool, true)
    enable_dns_support   = optional(bool, true)

    public_subnets = optional(list(object({
      cidr_block        = string
      availability_zone = string
      })), [
      {
        cidr_block        = "10.0.1.0/24"
        availability_zone = "us-east-1a"
      },
      {
        cidr_block        = "10.0.2.0/24"
        availability_zone = "us-east-1b"
      }
    ])

    private_subnets = optional(list(object({
      cidr_block        = string
      availability_zone = string
    })), [])

    enable_nat_gateway = optional(bool, false)
    single_nat_gateway = optional(bool, true)
    enable_vpn_gateway = optional(bool, false)
  })
  default = {}
}

# -----------------------------------------------------------------------------
# EC2 Module Variables
# -----------------------------------------------------------------------------

variable "create_ec2" {
  description = "Whether to create EC2 instances"
  type        = bool
  default     = false
}

variable "ec2_config" {
  description = "Configuration for EC2 instances"
  type = object({
    instance_count              = optional(number, 1)
    instance_type               = optional(string, "t3.micro")
    ami_id                      = optional(string, null)
    key_name                    = optional(string, null)
    subnet_id                   = optional(string, null)
    vpc_security_group_ids      = optional(list(string), [])
    associate_public_ip_address = optional(bool, true)

    root_block_device = optional(object({
      volume_type           = optional(string, "gp3")
      volume_size           = optional(number, 20)
      delete_on_termination = optional(bool, true)
      encrypted             = optional(bool, true)
    }), {})

    ebs_block_devices = optional(list(object({
      device_name           = string
      volume_type           = optional(string, "gp3")
      volume_size           = optional(number, 10)
      delete_on_termination = optional(bool, true)
      encrypted             = optional(bool, true)
    })), [])

    user_data                            = optional(string, null)
    disable_api_termination              = optional(bool, false)
    instance_initiated_shutdown_behavior = optional(string, "stop")
    monitoring                           = optional(bool, false)
  })
  default = {}
}

# -----------------------------------------------------------------------------
# RDS Module Variables
# -----------------------------------------------------------------------------

variable "create_rds" {
  description = "Whether to create RDS instance"
  type        = bool
  default     = false
}

variable "rds_config" {
  description = "Configuration for RDS instance"
  type = object({
    identifier     = optional(string, null)
    engine         = optional(string, "mysql")
    engine_version = optional(string, "8.0")
    instance_class = optional(string, "db.t3.micro")

    allocated_storage     = optional(number, 20)
    max_allocated_storage = optional(number, 100)
    storage_type          = optional(string, "gp3")
    storage_encrypted     = optional(bool, true)

    database_name = optional(string, "mydb")
    username      = optional(string, "admin")
    password      = optional(string, null)

    vpc_security_group_ids = optional(list(string), [])
    db_subnet_group_name   = optional(string, null)

    backup_retention_period = optional(number, 7)
    backup_window           = optional(string, "03:00-04:00")
    maintenance_window      = optional(string, "sun:04:00-sun:05:00")

    skip_final_snapshot       = optional(bool, true)
    final_snapshot_identifier = optional(string, null)
    deletion_protection       = optional(bool, false)

    monitoring_interval = optional(number, 0)
    multi_az            = optional(bool, false)
    publicly_accessible = optional(bool, false)
  })
  default = {}
}

# -----------------------------------------------------------------------------
# S3 Module Variables
# -----------------------------------------------------------------------------

variable "create_s3" {
  description = "Whether to create S3 bucket"
  type        = bool
  default     = false
}

variable "s3_config" {
  description = "Configuration for S3 bucket"
  type = object({
    bucket_name   = optional(string, null)
    force_destroy = optional(bool, false)

    versioning = optional(object({
      enabled = optional(bool, false)
    }), {})

    server_side_encryption_configuration = optional(object({
      rule = object({
        apply_server_side_encryption_by_default = object({
          sse_algorithm     = optional(string, "AES256")
          kms_master_key_id = optional(string, null)
        })
      })
    }), null)

    public_access_block = optional(object({
      block_public_acls       = optional(bool, true)
      block_public_policy     = optional(bool, true)
      ignore_public_acls      = optional(bool, true)
      restrict_public_buckets = optional(bool, true)
    }), {})

    lifecycle_configuration = optional(list(object({
      id     = string
      status = optional(string, "Enabled")

      expiration = optional(object({
        days = optional(number, null)
      }), null)

      noncurrent_version_expiration = optional(object({
        noncurrent_days = optional(number, null)
      }), null)

      transition = optional(list(object({
        days          = optional(number, null)
        storage_class = string
      })), [])
    })), [])

    notification_configuration = optional(object({
      cloudwatch_configuration = optional(list(object({
        events        = list(string)
        filter_prefix = optional(string, null)
        filter_suffix = optional(string, null)
      })), [])
    }), null)
  })
  default = {}
}

# -----------------------------------------------------------------------------
# Additional Module Toggles
# -----------------------------------------------------------------------------

variable "create_cloudwatch" {
  description = "Whether to create CloudWatch resources"
  type        = bool
  default     = false
}

variable "create_dynamodb" {
  description = "Whether to create DynamoDB table"
  type        = bool
  default     = false
}

variable "create_iam" {
  description = "Whether to create IAM resources"
  type        = bool
  default     = false
}

variable "create_sns" {
  description = "Whether to create SNS topic"
  type        = bool
  default     = false
}
