# Terraform Main Module: MyInfrastructure

This Terraform main module orchestrates the deployment of various AWS resources using submodules. It provides a comprehensive infrastructure setup for managing Amazon Virtual Private Cloud (VPC), security groups, Amazon S3 buckets, Amazon RDS databases, and Amazon EC2 instances. Below, you'll find detailed information on how to use this main module.

## Usage

```hcl
module "my_infrastructure" {
  source = "pradipbabar/my-infrastructure/aws"

  # Input variables for submodules
  vpc_config         = module.vpc.vpc_config
  security_group_ids = [module.security_groups.ec2_security_group_id]
  s3_config          = module.s3.s3_config
  rds_config         = module.rds.rds_config
  ec2_config         = module.ec2.ec2_config
}
```

## Inputs

### VPC Configuration (from `vpc` submodule)

| Name                | Description                                | Type   | Default     | Required |
| ------------------- | ------------------------------------------ | ------ | ----------- | :------: |
| vpc_config          | Configuration settings for the VPC.       | object |             |   yes    |

### Security Groups Configuration (from `security_groups` submodule)

| Name                | Description                                | Type   | Default     | Required |
| ------------------- | ------------------------------------------ | ------ | ----------- | :------: |
| security_group_ids  | List of security group IDs.                | list(string) | [] |   yes    |

### S3 Configuration (from `s3` submodule)

| Name                | Description                                | Type   | Default     | Required |
| ------------------- | ------------------------------------------ | ------ | ----------- | :------: |
| s3_config           | Configuration settings for S3 buckets.     | object |             |   yes    |

### RDS Configuration (from `rds` submodule)

| Name                | Description                                | Type   | Default     | Required |
| ------------------- | ------------------------------------------ | ------ | ----------- | :------: |
| rds_config          | Configuration settings for RDS instances. | object |             |   yes    |

### EC2 Configuration (from `ec2` submodule)

| Name                | Description                                | Type   | Default     | Required |
| ------------------- | ------------------------------------------ | ------ | ----------- | :------: |
| ec2_config          | Configuration settings for EC2 instances. | object |             |   yes    |

## Outputs

The main module does not provide any outputs directly. However, you can access the outputs from the submodules used within this main module.

### VPC Configuration (from `vpc` submodule)

| Name                | Description                             |
| ------------------- | --------------------------------------- |
| vpc_id              | The ID of the VPC.                      |
| public_subnets      | List of public subnet IDs.              |
| private_subnets     | List of private subnet IDs.             |
| nat_gateway_id      | ID of the NAT Gateway (if created).    |
| internet_gateway_id | ID of the Internet Gateway.             |
| public_route_table_id | ID of the public route table.        |
| private_route_table_id | ID of the private route table (if created). |

### Security Groups Configuration (from `security_groups` submodule)

| Name                | Description                             |
| ------------------- | --------------------------------------- |
| ec2_security_group_id | ID of the EC2 security group.         |

### S3 Configuration (from `s3` submodule)

| Name                | Description                             |
| ------------------- | --------------------------------------- |
| s3_bucket_ids       | List of S3 bucket IDs.                  |

### RDS Configuration (from `rds` submodule)

| Name                | Description                             |
| ------------------- | --------------------------------------- |
| rds_instance_ids    | List of RDS instance IDs.               |
| rds_instance_endpoints | List of RDS instance endpoints.     |

### EC2 Configuration (from `ec2` submodule)

| Name                | Description                             |
| ------------------- | --------------------------------------- |
| ec2_instance_ids    | List of EC2 instance IDs.               |
| ec2_instance_private_ips | List of private IP addresses for the EC2 instances. |
| ec2_instance_public_ips  | List of public IP addresses for the EC2 instances. |

## Submodules

### VPC Configuration (`vpc` submodule)

The `vpc` submodule deploys an Amazon Virtual Private Cloud (VPC) with public and private subnets, route tables, NAT Gateway, Internet Gateway, and more.

### Security Groups Configuration (`security_groups` submodule)

The `security_groups` submodule creates security groups that can be associated with EC2 instances or other AWS resources.

### S3 Configuration (`s3` submodule)

The `s3` submodule provisions Amazon S3 buckets with various configurations, including ACL, versioning, website settings, CORS rules, server-side encryption, and object lock settings.

### RDS Configuration (`rds` submodule)

The `rds` submodule deploys Amazon RDS database instances with customizable settings, including engine, storage, instance class, database name, and more.

### EC2 Configuration (`ec2` submodule)

The `ec2` submodule launches Amazon EC2 instances with options for instance type, AMI, subnet, security groups, key pairs, and more.

## Notes

- This main module allows you to orchestrate the deployment of various AWS resources using the submodules provided.
- Customize the input variables according to your specific infrastructure requirements.
- Ensure that you have the necessary AWS credentials and authentication configured for Terraform to create and manage resources in your AWS account.
- The outputs provided by the main module are based on the outputs exposed by the submodules used within it. Refer to the specific submodule documentation for more details on their outputs and configuration options.