# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Get the most recent Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  count       = var.create_ec2 && var.ec2_config.ami_id == null ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Random ID for unique resource naming
resource "random_id" "bucket_suffix" {
  count       = var.create_s3 && var.s3_config.bucket_name == null ? 1 : 0
  byte_length = 4
}

resource "random_password" "rds_password" {
  count   = var.create_rds && var.rds_config.password == null ? 1 : 0
  length  = 16
  special = true
}
