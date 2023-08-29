output "instance_id" {
    description = "instance id "
    value = aws_instance.web[*].id
  
}
output "instance_type" {
  description = "instance type"
  value = aws_instance.web[*].instance_type
}

output "ami" {
  description = "ami for ec2"
  value = aws_instance.web[*].ami
}
output "subnet_id" {
  description = "subnet id for ec2"
  value = aws_instance.web[*].subnet_id
}
output "security_groups" {
  description = "security group for ec2"
  value = aws_instance.web[*].security_groups
}
output "vpc_security_group_ids" {
  description = "vpc security group id"
  value = aws_instance.web[*].vpc_security_group_ids
}

output "user_data" {
  description = "user data for ec2"
  value = aws_instance.web[*].user_data
}

output "key_name" {
  description = "key name for ec2"
  value = aws_instance.web[*].key_name
}

output "tags" {
  description = "tags on ec2"
  value = aws_instance.web[*].tags
}
