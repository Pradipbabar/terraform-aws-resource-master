# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# VPC Configuration
# -----------------------------------------------------------------------------

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "VPC CIDR block must be a valid IPv4 CIDR."
  }
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# Subnet Configuration
# -----------------------------------------------------------------------------

variable "public_subnets" {
  description = "List of public subnet configurations"
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = []
}

variable "private_subnets" {
  description = "List of private subnet configurations"
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Gateway Configuration
# -----------------------------------------------------------------------------

variable "enable_nat_gateway" {
  description = "Enable NAT gateway for private subnets"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway for all private subnets"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable VPN gateway"
  type        = bool
  default     = false
}

variable "vpn_gateway_amazon_side_asn" {
  description = "ASN for the Amazon side of the VPN gateway"
  type        = number
  default     = 64512

  validation {
    condition = (
      var.vpn_gateway_amazon_side_asn >= 64512 && var.vpn_gateway_amazon_side_asn <= 65534
      ) || (
      var.vpn_gateway_amazon_side_asn >= 4200000000 && var.vpn_gateway_amazon_side_asn <= 4294967294
    )
    error_message = "ASN must be in the range 64512-65534 or 4200000000-4294967294."
  }
}

variable "enable_internet_gateway" {
  description = "Enable internet gateway"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Legacy Support (Deprecated)
# -----------------------------------------------------------------------------

variable "aws_region" {
  description = "[DEPRECATED] AWS region - use provider configuration instead"
  type        = string
  default     = null
}

variable "vpc_cidr_block" {
  description = "[DEPRECATED] Use cidr_block instead"
  type        = string
  default     = null
}

variable "public_subnet_1a_cidr_block" {
  description = "[DEPRECATED] Use public_subnets instead"
  type        = string
  default     = null
}

variable "public_subnet_1b_cidr_block" {
  description = "[DEPRECATED] Use public_subnets instead"
  type        = string
  default     = null
}

variable "private_subnet_1a_cidr_block" {
  description = "[DEPRECATED] Use private_subnets instead"
  type        = string
  default     = null
}

variable "private_subnet_1b_cidr_block" {
  description = "[DEPRECATED] Use private_subnets instead"
  type        = string
  default     = null
}

variable "private_ip_for_nat_gateway" {
  description = "[DEPRECATED] NAT gateway will use automatic IP allocation"
  type        = string
  default     = null
}

variable "craete_private_subnet" {
  description = "[DEPRECATED] Use private_subnets list instead"
  type        = bool
  default     = null
}

variable "existing_vpc_id" {
  description = "[DEPRECATED] This module creates a new VPC"
  type        = string
  default     = null
}