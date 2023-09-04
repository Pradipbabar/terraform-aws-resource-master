# Terraform Module: pradipbabar/resource-master/s3

This Terraform module deploys an Amazon S3 bucket in AWS with configurable settings. The module allows you to create a primary S3 bucket and an optional log bucket for logging. You can customize various attributes such as ACL, versioning, tags, website configuration, CORS rules, server-side encryption, object lock configuration, and logging settings.

## Usage

```hcl
module "my_s3_bucket" {
  source = "Pradipbabar/resource-master/aws//modules/s3"

  s3_bucket_name = "my-example-bucket"
  acl            = "private"
  force_destroy  = false
  versioning     = true

  website = {
    index_document = "index.html"
    error_document = "error.html"
  }

  cors_rule = {
    allowed_headers = ["Authorization"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  object_lock_configuration = {
    object_lock_enabled = "Enabled"
    rule = {
      default_retention = {
        mode = "GOVERNANCE"
        days = 30
      }
    }
  }

  tags = {
    Environment = "Development"
    Department  = "IT"
  }
}

module "my_s3_log_bucket" {
  source = "pradipbabar/resource-master/aws-s3"

  s3_bucket_name = "my-log-bucket"
  acl            = "private"
}
```

## Inputs

### Primary S3 Bucket

| Name                                    | Description                                    | Type    | Default     | Required |
| --------------------------------------- | ---------------------------------------------- | ------- | ----------- | :------: |
| s3_bucket_name                          | The name of the primary S3 bucket.            | string  |             |   yes    |
| acl                                     | The Access Control List (ACL) for the bucket. | string  | "private"   |    no    |
| force_destroy                           | Permanently delete the bucket when destroyed (true/false). | bool | false       |    no    |
| versioning                              | Enable versioning for the bucket (true/false). | bool   | false       |    no    |
| website                                 | Configuration settings for the S3 bucket's website. | object | {}        |    no    |
| cors_rule                               | Cross-Origin Resource Sharing (CORS) rule configuration. | object | {}        |    no    |
| server_side_encryption_configuration    | Configuration for server-side encryption.     | object  | {}        |    no    |
| object_lock_configuration                | Configuration for object lock.                | object  | {}        |    no    |
| tags                                    | Tags to apply to the primary S3 bucket.       | map(string) | {}     |    no    |

### Log S3 Bucket

| Name                                    | Description                                    | Type    | Default     | Required |
| --------------------------------------- | ---------------------------------------------- | ------- | ----------- | :------: |
| log_bucket_name                         | The name of the log S3 bucket.               | string  |             |   yes    |
| acl                                     | The Access Control List (ACL) for the log bucket. | string | "private"   |    no    |

## Outputs

### Primary S3 Bucket

| Name                  | Description                             |
| --------------------- | --------------------------------------- |
| s3_bucket_id          | The ID of the primary S3 bucket.       |

### Log S3 Bucket

| Name                  | Description                             |
| --------------------- | --------------------------------------- |
| log_bucket_id         | The ID of the log S3 bucket.           |

## Notes

- If `s3_bucket_name` or `log_bucket_name` is not provided, a default name with a timestamp will be generated for the respective buckets.
- You can customize the website configuration, CORS rules, server-side encryption, and object lock settings to meet your specific requirements.
- The module prevents the primary S3 bucket from being destroyed to avoid accidental data loss.