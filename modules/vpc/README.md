# Terraform Module: pradipbabar/resource-master/aws vpc

This Terraform module deploys a Virtual Private Cloud (VPC) in AWS with public and private subnets. It also provisions necessary route tables, associations, NAT Gateway, Elastic IP, and an Internet Gateway. The module is designed to be reusable and configurable.

## Usage

```hcl
module "my_vpc" {
  source = "Pradipbabar/resource-master/aws//modules/vpc"

  vpc_cidr_block             = "10.0.0.0/16"
  environment                = "dev"
  existing_vpc_id            = ""  # Use an existing VPC ID if available, leave empty to create a new VPC
  public_subnet_1a_cidr_block = "10.0.1.0/24"
  public_subnet_1b_cidr_block = "10.0.2.0/24"
  create_private_subnet      = true  # Set to true to create private subnets
  private_subnet_1a_cidr_block = "10.0.3.0/24"
  private_subnet_1b_cidr_block = "10.0.4.0/24"
  private_ip_for_nat_gateway = false  # Set to true to associate Elastic IP with NAT Gateway
}
```

## Inputs

| Name                          | Description                                     | Type     | Default       | Required |
| ----------------------------- | ----------------------------------------------- | -------- | ------------- | :------: |
| vpc_cidr_block                | The CIDR block for the VPC                     | string   |               |   yes    |
| environment                   | The environment name for resource tagging      | string   |               |   yes    |
| existing_vpc_id               | Existing VPC ID (leave empty for new VPC)      | string   | ""            |    no    |
| public_subnet_1a_cidr_block  | CIDR block for public subnet in us-east-1a    | string   |               |   yes    |
| public_subnet_1b_cidr_block  | CIDR block for public subnet in us-east-1b    | string   |               |   yes    |
| create_private_subnet         | Create private subnets (true/false)            | bool     | true          |    no    |
| private_subnet_1a_cidr_block | CIDR block for private subnet in us-east-1a   | string   |               |    no    |
| private_subnet_1b_cidr_block | CIDR block for private subnet in us-east-1b   | string   |               |    no    |
| private_ip_for_nat_gateway    | Associate Elastic IP with NAT Gateway (true/false) | bool | false         |    no    |

## Outputs

| Name                  | Description                             |
| --------------------- | --------------------------------------- |
| vpc_id                | The ID of the VPC                       |
| public_subnets        | List of public subnet IDs               |
| private_subnets       | List of private subnet IDs              |
| nat_gateway_id        | ID of the NAT Gateway (if created)     |
| internet_gateway_id   | ID of the Internet Gateway              |
| public_route_table_id | ID of the public route table            |
| private_route_table_id| ID of the private route table (if created) |

## Notes

- If you set `existing_vpc_id`, the module will use the existing VPC and create resources within it.
- To create private subnets, set `create_private_subnet` to `true`.
- If `private_ip_for_nat_gateway` is set to `true`, an Elastic IP will be associated with the NAT Gateway.
- The module uses default availability zones "us-east-1a" and "us-east-1b" for subnet creation but can be modified to suit your requirements.
- Ensure you have the necessary AWS credentials configured for Terraform to authenticate and create resources in your AWS account.