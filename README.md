# AWS Infrastructure Terraform Module

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)

A comprehensive, production-ready Terraform module for deploying AWS infrastructure components including VPC, EC2, RDS, S3, and other essential services.

## Features

✅ **Production-Ready**: Follows Terraform and AWS best practices  
✅ **Modular Design**: Enable/disable components as needed  
✅ **Flexible Configuration**: Extensive customization options  
✅ **Security-First**: Encrypted storage, private subnets, security groups  
✅ **Cost-Optimized**: Intelligent defaults for cost efficiency  
✅ **Well-Documented**: Comprehensive documentation and examples  
✅ **Backward Compatible**: Supports legacy configurations  

## Architecture

This module can deploy the following AWS resources:

- **VPC**: Virtual Private Cloud with public/private subnets, NAT gateways, route tables
- **EC2**: Elastic Compute instances with auto-scaling capabilities
- **RDS**: Relational Database Service with backup and monitoring
- **S3**: Simple Storage Service with encryption and lifecycle policies
- **IAM**: Identity and Access Management roles and policies
- **CloudWatch**: Monitoring and logging services
- **DynamoDB**: NoSQL database service
- **SNS**: Simple Notification Service

## Quick Start

### Basic Usage

```hcl
module "aws_infrastructure" {
  source = "Pradipbabar/resource-master/aws"
  
  # Basic configuration
  name_prefix = "my-project"
  environment = "dev"
  
  # Enable components
  create_vpc = true
  create_ec2 = true
  create_rds = true
  create_s3  = true
  
  # Common tags
  common_tags = {
    Project     = "MyProject"
    Environment = "Development"
    Owner       = "DevOps Team"
  }
}
```

### Advanced Usage

```hcl
module "aws_infrastructure" {
  source = "Pradipbabar/resource-master/aws"
  
  name_prefix = "production-app"
  environment = "prod"
  
  # VPC Configuration
  create_vpc = true
  vpc_config = {
    cidr_block = "10.0.0.0/16"
    
    public_subnets = [
      {
        cidr_block        = "10.0.1.0/24"
        availability_zone = "us-east-1a"
      },
      {
        cidr_block        = "10.0.2.0/24"
        availability_zone = "us-east-1b"
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
      }
    ]
    
    enable_nat_gateway = true
    single_nat_gateway = false
  }
  
  # EC2 Configuration
  create_ec2 = true
  ec2_config = {
    instance_count = 2
    instance_type  = "t3.medium"
    key_name       = "my-keypair"
    
    root_block_device = {
      volume_type = "gp3"
      volume_size = 30
      encrypted   = true
    }
    
    ebs_block_devices = [
      {
        device_name = "/dev/sdf"
        volume_size = 100
        volume_type = "gp3"
        encrypted   = true
      }
    ]
    
    user_data = base64encode(<<-EOF
      #!/bin/bash
      yum update -y
      yum install -y docker
      systemctl start docker
      systemctl enable docker
    EOF
    )
  }
  
  # RDS Configuration
  create_rds = true
  rds_config = {
    engine         = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    
    allocated_storage = 20
    storage_encrypted = true
    
    database_name = "myapp"
    username      = "admin"
    
    backup_retention_period = 7
    multi_az               = true
    deletion_protection    = true
  }
  
  # S3 Configuration
  create_s3 = true
  s3_config = {
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
    
    lifecycle_configuration = [
      {
        id     = "transition_to_ia"
        status = "Enabled"
        
        transition = [
          {
            days          = 30
            storage_class = "STANDARD_IA"
          },
          {
            days          = 60
            storage_class = "GLACIER"
          }
        ]
      }
    ]
  }
  
  # Common tags
  common_tags = {
    Project     = "ProductionApp"
    Environment = "Production"
    Team        = "Platform"
    CostCenter  = "Engineering"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |
| random | >= 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| vpc | ./modules/vpc | n/a |
| ec2 | ./modules/ec2 | n/a |
| rds | ./modules/rds | n/a |
| s3 | ./modules/s3 | n/a |
| cloudwatch | ./modules/cloudwatch | n/a |
| dynamodb | ./modules/dynamodb | n/a |
| iam | ./modules/iam | n/a |
| sns | ./modules/sns | n/a |

## Examples

### Simple Web Application

```hcl
module "web_app" {
  source = "Pradipbabar/resource-master/aws"
  
  name_prefix = "webapp"
  environment = "prod"
  
  create_vpc = true
  create_ec2 = true
  create_rds = true
  create_s3  = true
  
  vpc_config = {
    cidr_block = "10.0.0.0/16"
    enable_nat_gateway = true
  }
  
  ec2_config = {
    instance_count = 2
    instance_type  = "t3.small"
    key_name       = "webapp-key"
  }
  
  rds_config = {
    engine         = "mysql"
    instance_class = "db.t3.micro"
    database_name  = "webapp"
  }
}
```

## Best Practices

### Security

- All storage is encrypted by default
- Private subnets for database and application layers
- Security groups with minimal required access
- IAM roles with least privilege principle

### Cost Optimization

- Use appropriate instance types for workload
- Enable GP3 storage for better cost/performance ratio
- Configure lifecycle policies for S3
- Use single NAT gateway for non-production environments

### Monitoring

- Enable CloudWatch monitoring for all resources
- Configure log groups with appropriate retention
- Set up CloudWatch alarms for critical metrics

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Authors

- **Pradip Babar** - *Initial work* - [@Pradipbabar](https://github.com/Pradipbabar)
