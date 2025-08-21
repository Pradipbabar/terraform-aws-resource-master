terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Get VPC and subnet information
data "aws_vpc" "default" {
  count   = var.vpc_id == null && var.create_security_group ? 1 : 0
  default = true
}

data "aws_subnets" "default" {
  count = length(var.subnet_ids) == 0 ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [var.vpc_id != null ? var.vpc_id : data.aws_vpc.default[0].id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# Get availability zones for multi-AZ deployment
data "aws_availability_zones" "available" {
  count = var.multi_az_deployment ? 1 : 0
  state = "available"
}

# Latest Amazon Linux AMI
data "aws_ami" "amazon_linux" {
  count       = var.ami_id == null ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Local values
locals {
  ami_id = var.ami_id != null ? var.ami_id : data.aws_ami.amazon_linux[0].id

  vpc_id = var.vpc_id != null ? var.vpc_id : (
    var.create_security_group ? data.aws_vpc.default[0].id : null
  )

  # Enhanced subnet selection for multi-AZ
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : (
    length(data.aws_subnets.default) > 0 ? data.aws_subnets.default[0].ids : []
  )

  # Enhanced AZ distribution
  availability_zones = var.multi_az_deployment ? (
    length(var.preferred_availability_zones) > 0 ?
    var.preferred_availability_zones :
    data.aws_availability_zones.available[0].names
  ) : []

  # Instance to subnet/AZ mapping for multi-AZ
  instance_placements = {
    for i in range(var.instance_count) : i => {
      subnet_id = length(local.subnet_ids) > 0 ? local.subnet_ids[i % length(local.subnet_ids)] : null
      az        = var.multi_az_deployment && length(local.availability_zones) > 0 ? local.availability_zones[i % length(local.availability_zones)] : null
    }
  }

  security_group_ids = var.create_security_group ? [aws_security_group.this[0].id] : var.vpc_security_group_ids

  # Enhanced user data with CloudWatch agent
  user_data_script = var.enable_cloudwatch_agent || var.enable_ssm_agent ? templatefile("${path.module}/user_data.sh", {
    enable_cloudwatch_agent = var.enable_cloudwatch_agent
    enable_ssm_agent        = var.enable_ssm_agent
    log_group_name          = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.instance_logs[0].name : ""
    region                  = data.aws_region.current.name
    custom_user_data        = var.user_data != null ? base64decode(var.user_data) : ""
  }) : var.user_data

  common_tags = merge(
    {
      Name        = "${var.name_prefix}-${var.environment}"
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "ec2-standard"
      ModuleTier  = "standard"
      CreatedDate = formatdate("YYYY-MM-DD", timestamp())
    },
    var.common_tags
  )
}

# CloudWatch Log Group for instances
resource "aws_cloudwatch_log_group" "instance_logs" {
  count             = var.enable_cloudwatch_logs ? 1 : 0
  name              = "/aws/ec2/${var.name_prefix}-${var.environment}"
  retention_in_days = var.cloudwatch_log_retention

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-${var.environment}-logs"
      Type = "cloudwatch-log-group"
    }
  )
}

# Additional custom log groups
resource "aws_cloudwatch_log_group" "custom_logs" {
  for_each = {
    for log in var.custom_log_groups : log.name => log
  }

  name              = each.value.name
  retention_in_days = each.value.retention_in_days

  tags = merge(
    local.common_tags,
    {
      Name = each.value.name
      Type = "custom-log-group"
    }
  )
}

# IAM role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  count = var.create_iam_instance_profile ? 1 : 0
  name  = "${var.name_prefix}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# IAM policies for standard tier features
resource "aws_iam_role_policy" "ec2_standard_policy" {
  count = var.create_iam_instance_profile ? 1 : 0
  name  = "${var.name_prefix}-${var.environment}-ec2-standard-policy"
  role  = aws_iam_role.ec2_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # CloudWatch permissions
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      },
      # SSM permissions
      {
        Effect = "Allow"
        Action = [
          "ssm:UpdateInstanceInformation",
          "ssm:SendCommand",
          "ssm:ListCommands",
          "ssm:ListCommandInvocations",
          "ssm:DescribeInstanceInformation",
          "ssm:GetDeployablePatchSnapshotForInstance",
          "ssm:GetDefaultPatchBaseline",
          "ssm:GetManifest",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:ListAssociations",
          "ssm:ListInstanceAssociations",
          "ssm:PutInventory",
          "ssm:PutComplianceItems",
          "ssm:PutConfigurePackageResult",
          "ssm:UpdateAssociationStatus",
          "ssm:UpdateInstanceAssociationStatus"
        ]
        Resource = "*"
      },
      # EC2 permissions for instance metadata
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstanceAttribute",
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach AWS managed policies
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  count      = var.enable_ssm && var.create_iam_instance_profile ? 1 : 0
  role       = aws_iam_role.ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  count      = var.enable_cloudwatch_logs && var.create_iam_instance_profile ? 1 : 0
  role       = aws_iam_role.ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Additional IAM policies
resource "aws_iam_role_policy_attachment" "additional_policies" {
  for_each = var.create_iam_instance_profile ? toset(var.additional_iam_policies) : toset([])

  role       = aws_iam_role.ec2_role[0].name
  policy_arn = each.value
}

# IAM instance profile
resource "aws_iam_instance_profile" "this" {
  count = var.create_iam_instance_profile ? 1 : 0
  name  = "${var.name_prefix}-${var.environment}-instance-profile"
  role  = aws_iam_role.ec2_role[0].name

  tags = local.common_tags
}

# Enhanced Security Group
resource "aws_security_group" "this" {
  count       = var.create_security_group ? 1 : 0
  name        = "${var.name_prefix}-${var.environment}-sg"
  description = var.security_group_description
  vpc_id      = local.vpc_id

  # SSH access
  dynamic "ingress" {
    for_each = var.key_name != null && length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      from_port   = var.ssh_port
      to_port     = var.ssh_port
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidr_blocks
      description = "SSH access"
    }
  }

  # Application port
  dynamic "ingress" {
    for_each = var.application_port != null ? [1] : []
    content {
      from_port   = var.application_port
      to_port     = var.application_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Application port"
    }
  }

  # Outbound access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-${var.environment}-sg"
      Type = "security-group"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IPs
resource "aws_eip" "this" {
  count    = var.enable_elastic_ip ? var.instance_count : 0
  domain   = "vpc"
  instance = aws_instance.this[count.index].id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-${var.environment}-eip-${count.index + 1}"
      Type = "elastic-ip"
    }
  )

  depends_on = [aws_instance.this]
}

# User data template file
resource "local_file" "user_data_script" {
  count = var.enable_cloudwatch_agent || var.enable_ssm_agent ? 1 : 0

  filename = "${path.module}/user_data.sh"
  content = templatefile("${path.module}/templates/user_data.sh.tpl", {
    enable_cloudwatch_agent = var.enable_cloudwatch_agent
    enable_ssm_agent        = var.enable_ssm_agent
    log_group_name          = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.instance_logs[0].name : ""
    region                  = data.aws_region.current.name
  })
}

# EC2 Instances
resource "aws_instance" "this" {
  count = var.instance_count

  ami           = local.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Network configuration with enhanced placement
  subnet_id                   = local.instance_placements[count.index].subnet_id
  vpc_security_group_ids      = local.security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  availability_zone           = local.instance_placements[count.index].az

  # Storage configuration
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true

    tags = merge(
      local.common_tags,
      {
        Name = "${var.name_prefix}-${var.environment}-${count.index + 1}-root"
        Type = "root-volume"
      }
    )
  }

  # Enhanced instance configuration
  ebs_optimized        = var.enable_ebs_optimization
  monitoring           = var.enable_detailed_monitoring
  iam_instance_profile = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile
  user_data            = base64encode(local.user_data_script)

  # Placement configuration
  placement_group = var.placement_group
  tenancy         = var.tenancy

  # Security configuration
  disable_api_termination = var.disable_api_termination

  # Enhanced metadata options
  metadata_options {
    http_endpoint               = var.metadata_options.http_endpoint
    http_tokens                 = var.metadata_options.http_tokens
    http_put_response_hop_limit = var.metadata_options.http_put_response_hop_limit
    instance_metadata_tags      = "enabled"
  }

  tags = merge(
    local.common_tags,
    {
      Name           = "${var.name_prefix}-${var.environment}-${count.index + 1}"
      Index          = count.index + 1
      Type           = "ec2-instance"
      Tier           = "standard"
      BackupEnabled  = var.enable_backup
      MonitoringTier = "standard"
    }
  )

  volume_tags = merge(
    local.common_tags,
    {
      Name = "${var.name_prefix}-${var.environment}-${count.index + 1}-volume"
      Type = "ebs-volume"
    }
  )

  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }
}

# Include the remaining resources (CloudWatch alarms, backup, SNS, dashboard) in the next part
