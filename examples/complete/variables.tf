variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "ec2_key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = null
}
