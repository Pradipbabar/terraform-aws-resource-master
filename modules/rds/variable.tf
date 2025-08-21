# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "data_classification" {
  description = "Data classification level for compliance"
  type        = string
  default     = "Internal"

  validation {
    condition     = contains(["Public", "Internal", "Confidential", "Restricted"], var.data_classification)
    error_message = "Data classification must be one of: Public, Internal, Confidential, Restricted."
  }
}

# -----------------------------------------------------------------------------
# RDS Configuration Variables
# -----------------------------------------------------------------------------

variable "identifier" {
  description = "The name of the RDS instance"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.identifier))
    error_message = "Identifier must start with a letter and contain only alphanumeric characters and hyphens."
  }
}

variable "engine" {
  description = "The database engine"
  type        = string
  default     = "mysql"

  validation {
    condition = contains([
      "mysql", "postgres", "oracle-ee", "oracle-se2", "oracle-se1", "oracle-se",
      "sqlserver-ee", "sqlserver-se", "sqlserver-ex", "sqlserver-web",
      "aurora-mysql", "aurora-postgresql", "mariadb"
    ], var.engine)
    error_message = "Engine must be a valid RDS engine type."
  }
}

variable "engine_version" {
  description = "The engine version"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.micro"

  validation {
    condition     = can(regex("^db\\.", var.instance_class))
    error_message = "Instance class must be a valid RDS instance type starting with 'db.'."
  }
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20

  validation {
    condition     = var.allocated_storage >= 20
    error_message = "Allocated storage must be at least 20 GB."
  }
}

variable "max_allocated_storage" {
  description = "The upper limit for automatic storage scaling"
  type        = number
  default     = 100
}

variable "storage_type" {
  description = "The storage type for the RDS instance"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["standard", "gp2", "gp3", "io1", "io2"], var.storage_type)
    error_message = "Storage type must be one of: standard, gp2, gp3, io1, io2."
  }
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key"
  type        = string
  default     = null
}

variable "iops" {
  description = "The amount of provisioned IOPS"
  type        = number
  default     = null
}

variable "database_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
  default     = null
}

variable "username" {
  description = "Username for the master DB user"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "Password for the master DB user"
  type        = string
  default     = null
  sensitive   = true
}

variable "port" {
  description = "The port on which the DB accepts connections"
  type        = number
  default     = null
}

# -----------------------------------------------------------------------------
# Network Configuration
# -----------------------------------------------------------------------------

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
  default     = []
}

variable "db_subnet_group_name" {
  description = "Name of DB subnet group"
  type        = string
  default     = null
}

variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "The Availability Zone of the RDS instance"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# High Availability & Disaster Recovery
# -----------------------------------------------------------------------------

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "backup_window" {
  description = "The daily time range during which automated backups are created"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "The window to perform maintenance in"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before deletion"
  type        = bool
  default     = false # Changed to false for production safety
}

variable "final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB instance is deleted"
  type        = string
  default     = null
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled"
  type        = bool
  default     = true # Changed to true for production safety
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Performance and Monitoring
# -----------------------------------------------------------------------------

variable "monitoring_interval" {
  description = "The interval for collecting enhanced monitoring metrics"
  type        = number
  default     = 60

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Monitoring interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled"
  type        = bool
  default     = true
}

variable "performance_insights_retention_period" {
  description = "The amount of time in days to retain Performance Insights data"
  type        = number
  default     = 7

  validation {
    condition     = contains([7, 731], var.performance_insights_retention_period)
    error_message = "Performance Insights retention period must be either 7 days or 731 days (2 years)."
  }
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data"
  type        = string
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Parameter and Option Groups
# -----------------------------------------------------------------------------

variable "parameter_group_name" {
  description = "Name of the DB parameter group to associate"
  type        = string
  default     = null
}

variable "parameter_group_family" {
  description = "The DB parameter group family"
  type        = string
  default     = "mysql8.0"
}

variable "parameters" {
  description = "A list of DB parameters to apply"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "option_group_name" {
  description = "Name of the DB option group to associate"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Character Set and Timezone (Oracle/SQL Server)
# -----------------------------------------------------------------------------

variable "character_set_name" {
  description = "The character set name to use for DB encoding in Oracle instances"
  type        = string
  default     = null
}

variable "timezone" {
  description = "Time zone of the DB instance"
  type        = string
  default     = null
}

# -----------------------------------------------------------------------------
# Read Replica Configuration
# -----------------------------------------------------------------------------

variable "create_read_replica" {
  description = "Whether to create a read replica for disaster recovery"
  type        = bool
  default     = false
}

variable "read_replica_instance_class" {
  description = "The instance class for the read replica"
  type        = string
  default     = null
}

variable "read_replica_publicly_accessible" {
  description = "Bool to control if read replica is publicly accessible"
  type        = bool
  default     = false
}

variable "read_replica_vpc_security_group_ids" {
  description = "List of VPC security groups for read replica"
  type        = list(string)
  default     = null
}

variable "read_replica_availability_zone" {
  description = "The Availability Zone for the read replica"
  type        = string
  default     = null
}

variable "read_replica_monitoring_interval" {
  description = "Monitoring interval for read replica"
  type        = number
  default     = 0
}

variable "read_replica_performance_insights_enabled" {
  description = "Whether Performance Insights are enabled for read replica"
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# CloudWatch Alarms Configuration
# -----------------------------------------------------------------------------

variable "create_cloudwatch_alarms" {
  description = "Whether to create CloudWatch alarms"
  type        = bool
  default     = true
}

variable "alarm_sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
  default     = null
}

variable "cpu_utilization_threshold" {
  description = "CPU utilization threshold for CloudWatch alarm"
  type        = number
  default     = 80
}

variable "database_connections_threshold" {
  description = "Database connections threshold for CloudWatch alarm"
  type        = number
  default     = 80
}

variable "free_storage_space_threshold" {
  description = "Free storage space threshold in bytes for CloudWatch alarm"
  type        = number
  default     = 2000000000 # 2GB in bytes
}