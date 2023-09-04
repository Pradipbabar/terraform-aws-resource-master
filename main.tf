module "my_vpc" {
  source = "./modules/vpc"
    count = var.enable_vpc ? 1 : 0
  # VPC configuration here...
}

module "my_ec2_instances" {
  source = "./modules/ec2"
  count = var.enable_ec2 ? 1 : 0

  # EC2 instances configuration here...
}

module "my_rds_instance" {
  source = "./modules/rds"
  count = var.enable_rds ? 1 : 0

  # RDS instance configuration here...
}

module "my_s3_bucket" {
  source = "./modules/s3"
  count = var.enable_s3 ? 1 : 0

  # S3 bucket configuration here...
}

# Additional modules for CloudWatch, DynamoDB, etc.