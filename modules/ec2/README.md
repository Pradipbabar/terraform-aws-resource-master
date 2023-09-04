# Terraform Module: pradipbabar/resource-master/ec2

This Terraform module deploys Amazon EC2 instances in AWS. It includes the configuration of instance types, AMI, subnets, security groups, key pairs, public IP associations, IAM profiles, user data, and more.

## Usage

```hcl
module "my_ec2_instances" {
  source = "Pradipbabar/resource-master/aws//modules/ec2"

  ec2_count                 = 2
  instamce_type             = "t2.micro"
  ami                       = "ami-0123456789abcdef0"
  subnet_id                 = "subnet-0123456789abcdef0"
  security_groups           = [module.security_groups.ec2_security_group_id]
  key_name                  = "my-key-pair"

  associate_public_ip_address = true
  iam_instance_profile        = "my-instance-profile"
  user_data                   = "My user data script"
  disable_api_termination    = false
  instance_initiated_shutdown_behavior = "terminate"
  ebs_optimized           = true

  cpu_core_count          = 1
  cpu_threads_per_core   = 2

  root_volume_type        = "gp2"
  root_volume_size        = 30
  root_block_device_termination = true

  ebs_name                = "xvdf"
  ebs_volume_type         = "gp2"
  ebs_volume_size         = 50
  ebs_delete_termination  = false

  ec2_tag = {
    Name = "MyInstance"
    Environment = "Development"
  }

  ipv6_address_count      = 1
  tenancy                = "default"
}
```

## Inputs

| Name                          | Description                                         | Type       | Default       | Required |
| ----------------------------- | --------------------------------------------------- | ---------- | ------------- | :------: |
| ec2_count                     | The number of EC2 instances to create.             | number     |               |   yes    |
| instamce_type                 | The EC2 instance type.                              | string     |               |   yes    |
| ami                           | The Amazon Machine Image (AMI) ID.                 | string     |               |   yes    |
| subnet_id                     | The subnet ID for launching the EC2 instances.     | string     |               |   yes    |
| security_groups               | List of security group IDs.                         | list(string) | []          |    no    |
| key_name                      | The name of the key pair to use for the EC2 instances. | string  |               |   yes    |
| associate_public_ip_address   | Associate a public IP address with the EC2 instances (true/false). | bool | true       |    no    |
| iam_instance_profile          | The IAM instance profile name.                      | string     | ""            |    no    |
| user_data                     | The user data to provide to the EC2 instances.     | string     | ""            |    no    |
| disable_api_termination       | Disable EC2 instance termination using the API (true/false). | bool | false     |    no    |
| instance_initiated_shutdown_behavior | The behavior for stopping the EC2 instance (e.g., "terminate"). | string | "stop" | no |
| ebs_optimized                 | Enable EBS optimization for the EC2 instances (true/false). | bool  | false       |    no    |
| cpu_core_count                | The number of CPU cores.                           | number     | 1             |    no    |
| cpu_threads_per_core         | The number of threads per CPU core.               | number     | 1             |    no    |
| root_volume_type              | The root volume type.                               | string     | "gp2"         |    no    |
| root_volume_size              | The root volume size (in GB).                       | number     | 8             |    no    |
| root_block_device_termination | Terminate the root block device on instance termination (true/false). | bool | true | no |
| ebs_name                      | The name of the additional EBS volume.              | string     | ""            |    no    |
| ebs_volume_type               | The type of the additional EBS volume.              | string     | "gp2"         |    no    |
| ebs_volume_size               | The size of the additional EBS volume (in GB).      | number     | 20            |    no    |
| ebs_delete_termination        | Terminate the additional EBS volume on instance termination (true/false). | bool | true | no |
| ec2_tag                       | Tags to apply to the EC2 instances.                | map(string) | {}           |    no    |
| ipv6_address_count            | The number of IPv6 addresses to associate with the EC2 instances. | number | 0 | no |
| tenancy                       | The tenancy of the EC2 instances (default/dedicated). | string  | "default"    |    no    |

## Outputs

| Name                  | Description                                |
| --------------------- | ------------------------------------------ |
| ec2_instance_ids      | List of EC2 instance IDs.                  |
| ec2_instance_private_ips | List of private IP addresses for the EC2 instances. |
| ec2_instance_public_ips  | List of public IP addresses for the EC2 instances. |

## Notes

- This module assumes that you have already defined and configured the `vpc` and `security_groups` modules. Adjust the module references accordingly.
- Customize the module inputs to match your specific EC2 instance requirements, including instance types, AMIs, and user data.
- The module supports attaching additional EBS volumes to the EC2 instances.
- Make sure to configure security groups and other networking settings as needed.