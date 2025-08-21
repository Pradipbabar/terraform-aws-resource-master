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

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be lowercase, start and end with alphanumeric characters, and contain only letters, numbers, and hyphens."
  }
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket"
  type        = bool
  default     = false
}

variable "versioning" {
  description = "Versioning configuration"
  type = object({
    enabled    = optional(bool, true) # Default to enabled for DR
    mfa_delete = optional(bool, false)
  })
  default = {
    enabled = true
  }
}

variable "server_side_encryption_configuration" {
  description = "Server-side encryption configuration"
  type = object({
    rule = object({
      apply_server_side_encryption_by_default = object({
        sse_algorithm     = optional(string, "aws:kms") # Default to KMS for better security
        kms_master_key_id = optional(string, null)
      })
      bucket_key_enabled = optional(bool, true) # Cost optimization
    })
  })
  default = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "aws:kms"
      }
      bucket_key_enabled = true
    }
  }
}

variable "public_access_block" {
  description = "Public access block configuration"
  type = object({
    block_public_acls       = optional(bool, true)
    block_public_policy     = optional(bool, true)
    ignore_public_acls      = optional(bool, true)
    restrict_public_buckets = optional(bool, true)
  })
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

variable "lifecycle_configuration" {
  description = "Lifecycle configuration for cost optimization"
  type = list(object({
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

    noncurrent_version_transition = optional(list(object({
      noncurrent_days = optional(number, null)
      storage_class   = string
    })), [])

    abort_incomplete_multipart_upload = optional(object({
      days_after_initiation = optional(number, 7)
    }), null)
  }))
  default = []
}

# -----------------------------------------------------------------------------
# DISASTER RECOVERY Configuration
# -----------------------------------------------------------------------------

variable "replication_configuration" {
  description = "Cross-region replication configuration for disaster recovery"
  type = object({
    rules = list(object({
      id     = string
      status = optional(string, "Enabled")

      destination = object({
        bucket        = string
        storage_class = optional(string, "STANDARD_IA")
      })

      source_selection_criteria = optional(object({
        sse_kms_encrypted_objects = optional(object({
          status = optional(string, "Enabled")
        }), null)
      }), null)
    }))
  })
  default = null
}

variable "object_lock_configuration" {
  description = "Object lock configuration for compliance"
  type = object({
    rule = object({
      default_retention = object({
        mode = string
        days = optional(number, null)
      })
    })
  })
  default = null
}

variable "intelligent_tiering_configuration" {
  description = "Intelligent tiering configuration for cost optimization"
  type = object({
    name   = string
    status = optional(string, "Enabled")

    filter = optional(object({
      prefix = optional(string, null)
      tags   = optional(map(string), null)
    }), null)

    tiering = list(object({
      access_tier = string
      days        = optional(number, null)
    }))
  })
  default = null
}

variable "notification_configuration" {
  description = "Notification configuration for monitoring"
  type = object({
    lambda_function = optional(list(object({
      lambda_function_arn = string
      events              = list(string)
      filter_prefix       = optional(string, null)
      filter_suffix       = optional(string, null)
    })), null)

    topic = optional(list(object({
      topic_arn     = string
      events        = list(string)
      filter_prefix = optional(string, null)
      filter_suffix = optional(string, null)
    })), null)

    queue = optional(list(object({
      queue_arn     = string
      events        = list(string)
      filter_prefix = optional(string, null)
      filter_suffix = optional(string, null)
    })), null)
  })
  default = null
}

variable "logging_configuration" {
  description = "Access logging configuration"
  type = object({
    target_bucket = string
    target_prefix = optional(string, "access-logs/")
  })
  default = null
}

variable "cors_configuration" {
  description = "CORS configuration for web applications"
  type = object({
    cors_rule = list(object({
      allowed_headers = optional(list(string), null)
      allowed_methods = list(string)
      allowed_origins = list(string)
      expose_headers  = optional(list(string), null)
      max_age_seconds = optional(number, null)
    }))
  })
  default = null
}

variable "website_configuration" {
  description = "Website hosting configuration"
  type = object({
    index_document = optional(object({
      suffix = string
    }), null)

    error_document = optional(object({
      key = string
    }), null)

    redirect_all_requests_to = optional(object({
      host_name = string
      protocol  = optional(string, "https")
    }), null)
  })
  default = null
}
