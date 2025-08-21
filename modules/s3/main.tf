# -----------------------------------------------------------------------------
# S3 Bucket - Enhanced with Disaster Recovery and Security
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "main" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = merge(
    var.common_tags,
    {
      Name               = var.bucket_name
      Module             = "s3"
      BackupPolicy       = "Enabled"
      DataClassification = var.data_classification
    }
  )
}

# -----------------------------------------------------------------------------
# Versioning - CRITICAL for Disaster Recovery
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status     = var.versioning.enabled ? "Enabled" : "Suspended"
    mfa_delete = var.versioning.mfa_delete ? "Enabled" : "Disabled"
  }
}

# -----------------------------------------------------------------------------
# Server-Side Encryption - Security First
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.sse_algorithm
      kms_master_key_id = var.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.kms_master_key_id
    }
    bucket_key_enabled = var.server_side_encryption_configuration.rule.bucket_key_enabled
  }
}

# -----------------------------------------------------------------------------
# Public Access Block - Security Hardening
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = var.public_access_block.block_public_acls
  block_public_policy     = var.public_access_block.block_public_policy
  ignore_public_acls      = var.public_access_block.ignore_public_acls
  restrict_public_buckets = var.public_access_block.restrict_public_buckets
}

# -----------------------------------------------------------------------------
# Lifecycle Configuration - Cost Optimization & Data Management
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  count = length(var.lifecycle_configuration) > 0 ? 1 : 0

  bucket = aws_s3_bucket.main.id

  dynamic "rule" {
    for_each = var.lifecycle_configuration
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days = expiration.value.days
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value.noncurrent_days
        }
      }

      dynamic "transition" {
        for_each = rule.value.transition
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transition
        content {
          noncurrent_days = noncurrent_version_transition.value.noncurrent_days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload != null ? [rule.value.abort_incomplete_multipart_upload] : []
        content {
          days_after_initiation = abort_incomplete_multipart_upload.value.days_after_initiation
        }
      }
    }
  }
}

# -----------------------------------------------------------------------------
# Cross-Region Replication - DISASTER RECOVERY
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_replication_configuration" "main" {
  count = var.replication_configuration != null ? 1 : 0

  role   = aws_iam_role.replication[0].arn
  bucket = aws_s3_bucket.main.id

  dynamic "rule" {
    for_each = var.replication_configuration.rules
    content {
      id     = rule.value.id
      status = rule.value.status

      destination {
        bucket        = rule.value.destination.bucket
        storage_class = rule.value.destination.storage_class

        dynamic "access_control_translation" {
          for_each = rule.value.destination.access_control_translation != null ? [rule.value.destination.access_control_translation] : []
          content {
            owner = access_control_translation.value.owner
          }
        }
      }

      dynamic "source_selection_criteria" {
        for_each = rule.value.source_selection_criteria != null ? [rule.value.source_selection_criteria] : []
        content {
          dynamic "sse_kms_encrypted_objects" {
            for_each = source_selection_criteria.value.sse_kms_encrypted_objects != null ? [source_selection_criteria.value.sse_kms_encrypted_objects] : []
            content {
              status = sse_kms_encrypted_objects.value.status
            }
          }
        }
      }
    }
  }

  depends_on = [aws_s3_bucket_versioning.main]
}

# -----------------------------------------------------------------------------
# IAM Role for Replication - DISASTER RECOVERY
# -----------------------------------------------------------------------------

resource "aws_iam_role" "replication" {
  count = var.replication_configuration != null ? 1 : 0

  name = "${var.name_prefix}-s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.name_prefix}-s3-replication-role"
      Module = "s3"
    }
  )
}

resource "aws_iam_policy" "replication" {
  count = var.replication_configuration != null ? 1 : 0

  name = "${var.name_prefix}-s3-replication-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.main.arn}/*"
      },
      {
        Action = [
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = aws_s3_bucket.main.arn
      },
      {
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Effect = "Allow"
        Resource = [
          for rule in var.replication_configuration.rules : "${rule.destination.bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "replication" {
  count = var.replication_configuration != null ? 1 : 0

  role       = aws_iam_role.replication[0].name
  policy_arn = aws_iam_policy.replication[0].arn
}

# -----------------------------------------------------------------------------
# Bucket Notification - Monitoring & Automation
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_notification" "main" {
  count = var.notification_configuration != null ? 1 : 0

  bucket = aws_s3_bucket.main.id

  dynamic "lambda_function" {
    for_each = var.notification_configuration.lambda_function != null ? var.notification_configuration.lambda_function : []
    content {
      lambda_function_arn = lambda_function.value.lambda_function_arn
      events              = lambda_function.value.events
      filter_prefix       = lambda_function.value.filter_prefix
      filter_suffix       = lambda_function.value.filter_suffix
    }
  }

  dynamic "topic" {
    for_each = var.notification_configuration.topic != null ? var.notification_configuration.topic : []
    content {
      topic_arn     = topic.value.topic_arn
      events        = topic.value.events
      filter_prefix = topic.value.filter_prefix
      filter_suffix = topic.value.filter_suffix
    }
  }

  dynamic "queue" {
    for_each = var.notification_configuration.queue != null ? var.notification_configuration.queue : []
    content {
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = queue.value.filter_prefix
      filter_suffix = queue.value.filter_suffix
    }
  }
}

# -----------------------------------------------------------------------------
# Object Lock Configuration - Compliance & Data Protection
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_object_lock_configuration" "main" {
  count = var.object_lock_configuration != null ? 1 : 0

  bucket = aws_s3_bucket.main.id

  rule {
    default_retention {
      mode = var.object_lock_configuration.rule.default_retention.mode
      days = var.object_lock_configuration.rule.default_retention.days
    }
  }
}

# -----------------------------------------------------------------------------
# Intelligent Tiering - Cost Optimization
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_intelligent_tiering_configuration" "main" {
  count = var.intelligent_tiering_configuration != null ? 1 : 0

  bucket = aws_s3_bucket.main.id
  name   = var.intelligent_tiering_configuration.name

  status = var.intelligent_tiering_configuration.status

  dynamic "filter" {
    for_each = var.intelligent_tiering_configuration.filter != null ? [var.intelligent_tiering_configuration.filter] : []
    content {
      prefix = filter.value.prefix
      tags   = filter.value.tags
    }
  }

  dynamic "tiering" {
    for_each = var.intelligent_tiering_configuration.tiering
    content {
      access_tier = tiering.value.access_tier
      days        = tiering.value.days
    }
  }
}

# -----------------------------------------------------------------------------
# Logging Configuration - Audit Trail
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_logging" "main" {
  count = var.logging_configuration != null ? 1 : 0

  bucket = aws_s3_bucket.main.id

  target_bucket = var.logging_configuration.target_bucket
  target_prefix = var.logging_configuration.target_prefix
}

# -----------------------------------------------------------------------------
# CORS Configuration - Application Support
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_cors_configuration" "main" {
  count = var.cors_configuration != null ? 1 : 0

  bucket = aws_s3_bucket.main.id

  dynamic "cors_rule" {
    for_each = var.cors_configuration.cors_rule
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

# -----------------------------------------------------------------------------
# Website Configuration - Static Hosting
# -----------------------------------------------------------------------------

resource "aws_s3_bucket_website_configuration" "main" {
  count = var.website_configuration != null ? 1 : 0

  bucket = aws_s3_bucket.main.id

  dynamic "index_document" {
    for_each = var.website_configuration.index_document != null ? [var.website_configuration.index_document] : []
    content {
      suffix = index_document.value.suffix
    }
  }

  dynamic "error_document" {
    for_each = var.website_configuration.error_document != null ? [var.website_configuration.error_document] : []
    content {
      key = error_document.value.key
    }
  }

  dynamic "redirect_all_requests_to" {
    for_each = var.website_configuration.redirect_all_requests_to != null ? [var.website_configuration.redirect_all_requests_to] : []
    content {
      host_name = redirect_all_requests_to.value.host_name
      protocol  = redirect_all_requests_to.value.protocol
    }
  }
}
