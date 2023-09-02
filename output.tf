output "vpc_outputs" {
  description = "Outputs from the VPC module"
  value       = module.my_vpc[*].vpc_outputs  # Replace with actual module output variable names
  depends_on  = [module.my_vpc]
}

output "ec2_outputs" {
  description = "Outputs from the EC2 module"
  value       = module.my_ec2_instances[*].ec2_outputs  # Replace with actual module output variable names
  depends_on  = [module.my_ec2_instances]
}

output "rds_outputs" {
  description = "Outputs from the RDS module"
  value       = module.my_rds_instance[*].rds_outputs  # Replace with actual module output variable names
  depends_on  = [module.my_rds_instance]
}

output "s3_outputs" {
  description = "Outputs from the S3 module"
  value       = module.my_s3_bucket[*].s3_outputs  # Replace with actual module output variable names
  depends_on  = [module.my_s3_bucket]
}
