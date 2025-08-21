# -----------------------------------------------------------------------------
# VPC Outputs
# -----------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_enable_dns_support" {
  description = "Whether DNS support is enabled for the VPC"
  value       = aws_vpc.main.enable_dns_support
}

output "vpc_enable_dns_hostnames" {
  description = "Whether DNS hostnames are enabled for the VPC"
  value       = aws_vpc.main.enable_dns_hostnames
}

# -----------------------------------------------------------------------------
# Internet Gateway Outputs
# -----------------------------------------------------------------------------

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = var.enable_internet_gateway ? aws_internet_gateway.main[0].id : null
}

output "internet_gateway_arn" {
  description = "ARN of the Internet Gateway"
  value       = var.enable_internet_gateway ? aws_internet_gateway.main[0].arn : null
}

# -----------------------------------------------------------------------------
# Public Subnet Outputs
# -----------------------------------------------------------------------------

output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "public_subnet_arns" {
  description = "List of ARNs of the public subnets"
  value       = aws_subnet.public[*].arn
}

output "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "public_subnet_availability_zones" {
  description = "List of availability zones of the public subnets"
  value       = aws_subnet.public[*].availability_zone
}

# -----------------------------------------------------------------------------
# Private Subnet Outputs
# -----------------------------------------------------------------------------

output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "private_subnet_arns" {
  description = "List of ARNs of the private subnets"
  value       = aws_subnet.private[*].arn
}

output "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "private_subnet_availability_zones" {
  description = "List of availability zones of the private subnets"
  value       = aws_subnet.private[*].availability_zone
}

# -----------------------------------------------------------------------------
# Database Subnet Outputs
# -----------------------------------------------------------------------------

output "database_subnet_ids" {
  description = "List of IDs of the database subnets"
  value       = aws_subnet.database[*].id
}

output "database_subnet_group_id" {
  description = "ID of the database subnet group"
  value       = length(aws_db_subnet_group.main) > 0 ? aws_db_subnet_group.main[0].id : null
}

output "database_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = length(aws_db_subnet_group.main) > 0 ? aws_db_subnet_group.main[0].name : null
}

output "database_subnet_group_arn" {
  description = "ARN of the database subnet group"
  value       = length(aws_db_subnet_group.main) > 0 ? aws_db_subnet_group.main[0].arn : null
}

# -----------------------------------------------------------------------------
# NAT Gateway Outputs
# -----------------------------------------------------------------------------

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public IPs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].public_ip
}

output "nat_eip_ids" {
  description = "List of IDs of the Elastic IPs for NAT Gateways"
  value       = aws_eip.nat[*].id
}

output "nat_eip_public_ips" {
  description = "List of public IPs of the Elastic IPs for NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

# -----------------------------------------------------------------------------
# Route Table Outputs
# -----------------------------------------------------------------------------

output "public_route_table_ids" {
  description = "List of IDs of the public route tables"
  value       = aws_route_table.public[*].id
}

output "private_route_table_ids" {
  description = "List of IDs of the private route tables"
  value       = aws_route_table.private[*].id
}

output "database_route_table_ids" {
  description = "List of IDs of the database route tables"
  value       = aws_route_table.database[*].id
}

# -----------------------------------------------------------------------------
# VPN Gateway Outputs
# -----------------------------------------------------------------------------

output "vpn_gateway_id" {
  description = "ID of the VPN Gateway"
  value       = var.enable_vpn_gateway ? aws_vpn_gateway.main[0].id : null
}

output "vpn_gateway_arn" {
  description = "ARN of the VPN Gateway"
  value       = var.enable_vpn_gateway ? aws_vpn_gateway.main[0].arn : null
}

# -----------------------------------------------------------------------------
# Default Security Group Outputs
# -----------------------------------------------------------------------------

output "default_security_group_id" {
  description = "ID of the default security group"
  value       = aws_default_security_group.default.id
}

# -----------------------------------------------------------------------------
# Legacy Outputs (for backward compatibility)
# -----------------------------------------------------------------------------

output "public_subnet_1a_id" {
  description = "[DEPRECATED] Use public_subnet_ids[0] instead"
  value       = length(aws_subnet.public) > 0 ? aws_subnet.public[0].id : null
}

output "public_subnet_1b_id" {
  description = "[DEPRECATED] Use public_subnet_ids[1] instead"
  value       = length(aws_subnet.public) > 1 ? aws_subnet.public[1].id : null
}

output "private_subnet_1a_id" {
  description = "[DEPRECATED] Use private_subnet_ids[0] instead"
  value       = length(aws_subnet.private) > 0 ? aws_subnet.private[0].id : null
}

output "private_subnet_1b_id" {
  description = "[DEPRECATED] Use private_subnet_ids[1] instead"
  value       = length(aws_subnet.private) > 1 ? aws_subnet.private[1].id : null
}
