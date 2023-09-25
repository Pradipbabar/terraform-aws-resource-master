variable "ami" {
  description = "ami id "
  default     = "ami-830c94e3"
}
variable "availability_zone" {
  description = "availability zone "
  default     = "us-east-1a"
}
variable "associate_public_ip_address" {
  type        = bool
  description = "associate public ip adress (true/false)"
  default     = true
}

variable "ec2_count" {
  description = "ec2 count"
  default     = 1
}

variable "instamce_type" {
  description = "instance type "
  default     = "t2.micro"
}

variable "root_volume_size" {
  description = "Root storage size"
  default     = null
}

variable "subnet_id" {
  description = "subnet id "
  default     = ""
}
variable "http_endpoint" {
  description = "endpoints"
  default     = "enabled"
}
variable "security_groups" {
  default = ["default"]
}

variable "vpc_security_group_ids" {
  description = "vpc security group id "
  default = ["sg-12345678"]
}

variable "key_name" {
  description = "key pair name]"
  default = "my-key-pair"
}

variable "cpu_core_count" {
  description = "cpu core count"
  default = null
}
variable "cpu_threads_per_core" {
  description = "cpu threads per core"
  default = null
}
variable "disable_api_termination" {
  description = "disable_api_termination" 
  default = false  
}

variable "ebs_optimized" {
  description = "ebs optomized"
  default = false
  
}

variable "root_volume_type" {
  description = "root volume type"
  default = "gp2"
}
variable "root_block_device_termination" {
  description = "root block device termination"
  default = true
}

variable "ebs_name" {
  description = "ebs block device name"
  default = ""
  
}
variable "ebs_volume_type" {
  description = "ebs volume type"
  default = "gp2"
}
variable "ebs_volume_size" {
  description = "ebs volume size"
  default = null
  
}
variable "ebs_delete_termination" {
  description = "ebs delete on termination"
  default = true
  
}

variable "ec2_tag" {
  description = "ec2 tags"
  default = {}
}

variable "ipv6_address_count" {
  description = "ipv6 address count"
  default = null
}

variable "iam_instance_profile" {
  description = "iam instance profile "
  default = ""
}

variable "user_data" {
  description = "user data"
  default = ""
}

variable "instance_initiated_shutdown_behavior" {
  description = "inmstnce shutdown behavior "
  default = "terminate"
}

variable "tenancy" {
  description = "tanancy"
  default = "default"
}