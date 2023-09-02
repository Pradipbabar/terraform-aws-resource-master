module "my_vpc" {
  source = "pradipbabar/resource-master/aws-vpc"
    count = var.enable_vpc ? 1 : 0
  # VPC configuration here...
}

module "my_ec2_instances" {
  source = "pradipbabar/resource-master/aws-ec2"
  count = var.enable_ec2 ? 1 : 0

  # EC2 instances configuration here...
}

module "my_rds_instance" {
  source = "pradipbabar/resource-master/aws-rds"
  count = var.enable_rds ? 1 : 0

  # RDS instance configuration here...
}

module "my_s3_bucket" {
  source = "pradipbabar/resource-master/aws-s3"
  count = var.enable_s3 ? 1 : 0

  # S3 bucket configuration here...
}

# Additional modules for CloudWatch, DynamoDB, etc.