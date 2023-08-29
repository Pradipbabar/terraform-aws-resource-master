variable "aws_region" {
  default     = "us-east-1"
  description = "AWS REGION"
}

variable "environment" {
  default     = "DEV"
  description = "Environment name used a sprefix"
}


variable "vpc_cidr_block" {
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

variable "public_subnet_1a_cidr_block" {
  description = "value of the public subnet 1a cidr block"
  default = "10.0.1.0/24"
}

variable "public_subnet_1b_cidr_block" {
  description = "value of the public subnet 1b cidr block"
  default = "10.0.2.0/24"
}

variable "private_subnet_1a_cidr_block" {
  description = "value of the private subnet 1a cidr block"
  default = "10.0.10.0/24"
}

variable "private_subnet_1b_cidr_block" {
  description = "value of the private subnet 1b cidr block"
  default = "10.0.11.0/24"
}

variable "private_ip_for_nat_gateway" {
  description = "value of the elastic ip for nat gateway public ip"
  default = "10.0.0.5"

}

variable "craete_private_subnet" {
  type = bool
  default =false
}

variable "existing_vpc_id" {
  description = "existing vpc id "
  default = ""
}