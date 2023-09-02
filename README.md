# Terraform Main Module: My AWS Infrastructure

This Terraform main module orchestrates the deployment of various AWS resources by leveraging the capabilities of submodules. The main module is designed to create and manage a wide range of AWS resources, including a VPC, EC2 instances, RDS databases, Amazon S3 buckets, security groups, and more. Additionally, it uses submodules for specific resource types such as CloudWatch alarms and DynamoDB tables.

## Prerequisites

Before you begin, ensure that you have the following prerequisites set up:

- AWS account with appropriate permissions.
- Terraform installed on your local machine.
- AWS CLI configured with valid credentials.

## Usage

### 1. Simple usage 
```hcl
module "resourse_master" {
  enable_rds = true
  enable_vpc = true
  enable_s3 = true
  enable_ec2 = true


}
```

### 2. Define Your Configuration

Create a Terraform configuration file (e.g., `main.tf`) to define your infrastructure configuration. In this file, you can specify the resources you want to create and configure.

```hcl
module "my_vpc" {
  source = "pradipbabar/resource-master/aws-vpc"

  # VPC configuration here...
}

module "my_ec2_instances" {
  source = "pradipbabar/resource-master/aws-ec2"

  # EC2 instances configuration here...
}

module "my_rds_instance" {
  source = "pradipbabar/resource-master/aws-rds"

  # RDS instance configuration here...
}

module "my_s3_bucket" {
  source = "pradipbabar/resource-master/aws-s3"

  # S3 bucket configuration here...
}

# Additional modules for CloudWatch, DynamoDB, etc.
```

### 3. Initialize Terraform

Run the following command to initialize Terraform and download the required providers and modules:

```bash
terraform init
```

### 4. Apply the Configuration

Deploy your AWS infrastructure by running:

```bash
terraform apply
```

Terraform will show you the plan and ask for confirmation before applying the changes.

### 5. Destroy Resources (Optional)

If you need to tear down the resources, you can use the following command:

```bash
terraform destroy
```

## Submodules

### AWS VPC (Virtual Private Cloud)

The `aws-vpc` submodule creates a Virtual Private Cloud in AWS, including public and private subnets, route tables, and necessary associations.

### AWS EC2 Instances

The `aws-ec2` submodule deploys Amazon EC2 instances in the VPC with configurable attributes such as instance types, AMIs, security groups, and more.

### AWS RDS (Relational Database Service)

The `aws-rds` submodule provisions Amazon RDS database instances with customizable settings, including engine, storage, instance class, and more.

### AWS S3 Buckets

The `aws-s3` submodule manages Amazon S3 buckets, allowing you to create primary and log buckets with various configurations.

### Additional Submodules

Extend the main module by adding additional submodules to create and manage resources like CloudWatch alarms, DynamoDB tables, Lambda functions, etc., according to your specific requirements.

## Outputs

Each submodule may have its own set of outputs that you can use in your main configuration or other submodules. Refer to the specific submodule's documentation for details on available outputs.

## Contributing

Feel free to contribute to this Terraform infrastructure module by creating pull requests, reporting issues, or suggesting improvements. Your contributions are highly appreciated!

## License

This Terraform module is open-source and available under the [MIT License](LICENSE).

---

_Replace "pradipbabar/resource-master" with the actual path to your submodules or use the appropriate Terraform registry paths._