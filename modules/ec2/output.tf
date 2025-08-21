# -----------------------------------------------------------------------------
# Output Values for EC2 Module
# -----------------------------------------------------------------------------

# Basic Instance Information
output "instance_ids" {
  description = "List of instance IDs"
  value       = aws_instance.main[*].id
}

output "instance_arns" {
  description = "List of instance ARNs"
  value       = aws_instance.main[*].arn
}

output "instance_public_ips" {
  description = "List of public IP addresses assigned to instances"
  value       = aws_instance.main[*].public_ip
}

output "instance_private_ips" {
  description = "List of private IP addresses assigned to instances"
  value       = aws_instance.main[*].private_ip
}

output "instance_public_dns" {
  description = "List of public DNS names assigned to instances"
  value       = aws_instance.main[*].public_dns
}

output "instance_private_dns" {
  description = "List of private DNS names assigned to instances"
  value       = aws_instance.main[*].private_dns
}

output "instance_subnet_ids" {
  description = "List of subnet IDs where instances are placed"
  value       = aws_instance.main[*].subnet_id
}

output "instance_vpc_security_group_ids" {
  description = "List of VPC security group IDs associated with instances"
  value       = aws_instance.main[*].vpc_security_group_ids
}

output "instance_key_name" {
  description = "Key name used for instances"
  value       = length(aws_instance.main) > 0 ? aws_instance.main[0].key_name : null
}

# Enhanced Security and Configuration
output "instance_state" {
  description = "Current state of instances"
  value       = aws_instance.main[*].instance_state
}

output "instance_type" {
  description = "Instance type used"
  value       = length(aws_instance.main) > 0 ? aws_instance.main[0].instance_type : null
}

output "root_block_device_volume_ids" {
  description = "List of root volume IDs"
  value       = aws_instance.main[*].root_block_device[0].volume_id
}

output "ebs_block_device_volume_ids" {
  description = "List of additional EBS volume IDs"
  value       = flatten([for instance in aws_instance.main : [for device in instance.ebs_block_device : device.volume_id]])
}

# Elastic IP Information
output "elastic_ip_addresses" {
  description = "List of Elastic IP addresses"
  value       = aws_eip.main[*].public_ip
}

output "elastic_ip_allocation_ids" {
  description = "List of Elastic IP allocation IDs"
  value       = aws_eip.main[*].allocation_id
}

# IAM Information
output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = var.create_iam_instance_profile ? aws_iam_instance_profile.ec2_profile[0].name : null
}

output "iam_role_arn" {
  description = "ARN of the IAM role"
  value       = var.create_iam_instance_profile ? aws_iam_role.ec2_role[0].arn : null
}

# Monitoring and Backup Information
output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = var.enable_detailed_monitoring ? aws_cloudwatch_log_group.instance_logs[0].name : null
}

output "backup_vault_name" {
  description = "Name of the backup vault"
  value       = var.enable_backup ? aws_backup_vault.main[0].name : null
}

output "backup_plan_id" {
  description = "ID of the backup plan"
  value       = var.enable_backup ? aws_backup_plan.main[0].id : null
}

output "cpu_alarm_names" {
  description = "Names of CPU utilization CloudWatch alarms"
  value       = var.enable_detailed_monitoring ? aws_cloudwatch_metric_alarm.cpu_utilization[*].alarm_name : []
}

output "status_check_alarm_names" {
  description = "Names of status check CloudWatch alarms"
  value       = var.enable_detailed_monitoring ? aws_cloudwatch_metric_alarm.status_check_failed[*].alarm_name : []
}

# Security Features
output "metadata_options" {
  description = "Metadata options configuration"
  value = length(aws_instance.main) > 0 ? {
    http_endpoint               = aws_instance.main[0].metadata_options[0].http_endpoint
    http_tokens                 = aws_instance.main[0].metadata_options[0].http_tokens
    http_put_response_hop_limit = aws_instance.main[0].metadata_options[0].http_put_response_hop_limit
    instance_metadata_tags      = aws_instance.main[0].metadata_options[0].instance_metadata_tags
  } : null
}

output "monitoring_enabled" {
  description = "Whether detailed monitoring is enabled"
  value       = var.enable_detailed_monitoring
}

output "backup_enabled" {
  description = "Whether backup is enabled"
  value       = var.enable_backup
}

output "ssm_managed" {
  description = "Whether instances are managed by Systems Manager"
  value       = var.enable_ssm_managed
}
