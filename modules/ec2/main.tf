module "vpc" {
  source = "../vpc/"

}

module "security_groups" {
  source = "../security_group"
}

resource "aws_instance" "web" {
  count = var.ec2_count
  instance_type   = var.instamce_type
  ami             = var.ami
  subnet_id       = var.subnet_id != "" ? var.subnet_id : module.vpc.public_subnet_1a_id
  security_groups = var.security_groups
  vpc_security_group_ids = var.vpc_security_group_ids != "" ? var.vpc_security_group_ids : [module.security_groups.ec2_vpc_security_groupid]   # Replace with security group IDs
  key_name              = var.key_name     # Replace with your key pair name

  associate_public_ip_address = var.associate_public_ip_address
  iam_instance_profile        = var.iam_instance_profile
  user_data                   = var.user_data

  disable_api_termination    = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  ebs_optimized           = var.ebs_optimized
  


  cpu_core_count        = var.cpu_core_count
  cpu_threads_per_core = var.cpu_threads_per_core

  root_block_device {
    volume_type = var.root_volume_type
    volume_size = var.root_volume_size
    delete_on_termination = var.root_block_device_termination
  }

  ebs_block_device {
    device_name = var.ebs_name
    volume_type = var.ebs_volume_type
    volume_size = var.ebs_volume_size
    delete_on_termination = var.ebs_delete_termination
  }

  tags = var.ec2_tag

  ipv6_address_count = var.ipv6_address_count
  
  tenancy = var.tenancy



 
}


