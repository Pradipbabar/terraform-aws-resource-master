output "bucket_name" {
    description = "bucket name"
    value = aws_s3_bucket.example_bucket.id
   }

output "bucket_arn" {
    description = "Bucket arn"
    value = aws_s3_bucket.example_bucket.arn
   }

output "bucket_domain_name" {
    description = "bucket domain name"
    value = aws_s3_bucket.example_bucket.bucket_domain_name
   }

output "bucket_region" {
    description = "bucket region"
    value = aws_s3_bucket.example_bucket.region
   }
output "bucket_website_url" {
    description = "bucket website_url"
    value = aws_s3_bucket.example_bucket.website_endpoint
   }

output "bucket_versioning_status" {
    description = "bucket versioning status"
    value = aws_s3_bucket.example_bucket.versioning[0].enabled
   }
output "bucket_tags" {
    description = "bucket tags"
    value = aws_s3_bucket.example_bucket.tags
   }

output "bucket_acl" {
    description = "bucket acl"
    value = aws_s3_bucket.example_bucket.acl
   }