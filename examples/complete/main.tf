# Complete Production Example
# This example demonstrates all features of the module for production deployment

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  name_prefix = "prod-webapp"
  environment = "production"

  common_tags = {
    Project     = "WebApplication"
    Environment = "Production"
    Team        = "Platform"
    CostCenter  = "Engineering"
    ManagedBy   = "Terraform"
  }
}

module "complete_infrastructure" {
  source = "../../"

  name_prefix = local.name_prefix
  environment = local.environment
  common_tags = local.common_tags

  # VPC Configuration - Multi-AZ with private subnets
  create_vpc = true
  vpc_config = {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support   = true

    public_subnets = [
      {
        cidr_block        = "10.0.1.0/24"
        availability_zone = "us-east-1a"
      },
      {
        cidr_block        = "10.0.2.0/24"
        availability_zone = "us-east-1b"
      },
      {
        cidr_block        = "10.0.3.0/24"
        availability_zone = "us-east-1c"
      }
    ]

    private_subnets = [
      {
        cidr_block        = "10.0.10.0/24"
        availability_zone = "us-east-1a"
      },
      {
        cidr_block        = "10.0.11.0/24"
        availability_zone = "us-east-1b"
      },
      {
        cidr_block        = "10.0.12.0/24"
        availability_zone = "us-east-1c"
      }
    ]

    enable_nat_gateway = true
    single_nat_gateway = false # Multi-AZ NAT for production
    enable_vpn_gateway = false
  }

  # EC2 Configuration - Auto Scaling Group with Load Balancer
  create_ec2 = true
  ec2_config = {
    instance_count = 3
    instance_type  = "t3.medium"
    key_name       = var.ec2_key_name

    # Storage configuration
    root_block_device = {
      volume_type           = "gp3"
      volume_size           = 30
      delete_on_termination = true
      encrypted             = true
    }

    ebs_block_devices = [
      {
        device_name           = "/dev/sdf"
        volume_type           = "gp3"
        volume_size           = 100
        delete_on_termination = true
        encrypted             = true
      }
    ]

    # Security and monitoring
    monitoring                           = true
    disable_api_termination              = false
    instance_initiated_shutdown_behavior = "stop"

    # IAM
    create_iam_instance_profile = true
    iam_role_policies = [
      "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
      "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    ]

    # User data for application setup
    user_data = base64encode(templatefile("${path.module}/userdata.sh", {
      environment = local.environment
    }))
  }

  # RDS Configuration - Multi-AZ MySQL with backup
  create_rds = true
  rds_config = {
    identifier     = "${local.name_prefix}-db"
    engine         = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"

    allocated_storage     = 100
    max_allocated_storage = 1000
    storage_type          = "gp3"
    storage_encrypted     = true

    database_name = "webapp"
    username      = "admin"
    # password will be auto-generated

    backup_retention_period = 30
    backup_window           = "03:00-04:00"
    maintenance_window      = "sun:04:00-sun:05:00"

    skip_final_snapshot = false
    deletion_protection = true

    monitoring_interval = 60
    multi_az            = true
    publicly_accessible = false
  }

  # S3 Configuration - With lifecycle and encryption
  create_s3 = true
  s3_config = {
    force_destroy = false

    versioning = {
      enabled = true
    }

    server_side_encryption_configuration = {
      rule = {
        apply_server_side_encryption_by_default = {
          sse_algorithm = "AES256"
        }
      }
    }

    public_access_block = {
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    }

    lifecycle_configuration = [
      {
        id     = "main"
        status = "Enabled"

        expiration = {
          days = 2555 # 7 years
        }

        noncurrent_version_expiration = {
          noncurrent_days = 90
        }

        transition = [
          {
            days          = 30
            storage_class = "STANDARD_IA"
          },
          {
            days          = 60
            storage_class = "GLACIER"
          },
          {
            days          = 180
            storage_class = "DEEP_ARCHIVE"
          }
        ]
      }
    ]
  }

  # Additional services
  create_cloudwatch = true
  create_iam        = true
  create_sns        = true
}
