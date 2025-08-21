# Simple Usage Example
# This example creates basic AWS infrastructure with VPC, EC2, and S3

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
  region = "us-east-1"
}

module "simple_infrastructure" {
  source = "../../"

  # Basic configuration
  name_prefix = "simple-example"
  environment = "dev"

  # Enable core components
  create_vpc = true
  create_ec2 = true
  create_s3  = true

  # VPC with basic configuration
  vpc_config = {
    cidr_block         = "10.0.0.0/16"
    enable_nat_gateway = false # Cost optimization for simple setup
  }

  # Single EC2 instance
  ec2_config = {
    instance_count = 1
    instance_type  = "t3.micro"
  }

  # Basic S3 bucket
  s3_config = {
    versioning = {
      enabled = false
    }
  }

  # Common tags
  common_tags = {
    Project     = "SimpleExample"
    Environment = "Development"
    Owner       = "DevOps"
  }
}

# Outputs
output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.simple_infrastructure.vpc_id
}

output "instance_ids" {
  description = "IDs of the created EC2 instances"
  value       = module.simple_infrastructure.ec2.instance_ids
}

output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = module.simple_infrastructure.s3_outputs
}
