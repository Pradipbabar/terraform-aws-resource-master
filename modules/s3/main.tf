resource "aws_s3_bucket" "example_bucket" {
  bucket = var.s3_bucket_name != "" ? var.s3_bucket_name : "bucket_${timestamp()}"
  acl    = var.acl
  force_destroy = var.force_destroy
  versioning {

    enabled = var.versioning
  }
  tags = var.tags

  website {
    index_document = var.website.index_document
    error_document = var.website.error_document
  }

  cors_rule {
    allowed_headers = var.cors_rule.allowed_headers
    allowed_methods = var.cors_rule.allowed_methods
    allowed_origins = var.cors_rule.allowed_origins
    expose_headers  = var.cors_rule.expose_headers
    max_age_seconds = var.cors_rule.max_age_seconds
  }

  lifecycle {
    prevent_destroy = true
  }


  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.sse_algorithm
      }
    }
  }

  object_lock_configuration {
    object_lock_enabled = "Enabled"
    rule {
      default_retention {
        mode = "COMPLIANCE"
        days = 365
      }
    }
  }

  logging {
    target_bucket = aws_s3_bucket.logs_bucket.id
    target_prefix = "logs/"
  }
}

resource "aws_s3_bucket" "logs_bucket" {
  bucket = var.log_bucket_name != "" ? var.log_bucket_name : "log_bucket_${timestamp()}"
  acl = "private"

}