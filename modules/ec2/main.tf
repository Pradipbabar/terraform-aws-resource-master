# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

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

data "aws_subnets" "default" {
  count = length(var.subnet_ids) == 0 ? 1 : 0

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

# Get KMS key for EBS encryption
data "aws_kms_key" "ebs" {
  count  = 1
  key_id = "alias/aws/ebs"
}

# -----------------------------------------------------------------------------
# IAM Role for EC2 with Enhanced Permissions
# -----------------------------------------------------------------------------

# CloudWatch Agent Policy for detailed monitoring
resource "aws_iam_policy" "cloudwatch_agent" {
  count = var.create_iam_instance_profile && var.enable_detailed_monitoring ? 1 : 0

  name        = "${var.name_prefix}-cloudwatch-agent-policy"
  description = "Policy for CloudWatch agent on EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.module_tags
}

# Systems Manager Policy for patch management and remote access
resource "aws_iam_policy" "ssm_managed" {
  count = var.create_iam_instance_profile && var.enable_ssm_managed ? 1 : 0

  name        = "${var.name_prefix}-ssm-managed-policy"
  description = "Policy for Systems Manager managed instances"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel",
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.module_tags
}

resource "aws_iam_role" "ec2_role" {
  count = var.create_iam_instance_profile ? 1 : 0

  name = "${var.name_prefix}-ec2-role"

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

  tags = local.module_tags
}

resource "aws_iam_role_policy_attachment" "ec2_role_policies" {
  count = var.create_iam_instance_profile ? length(var.iam_role_policies) : 0

  role       = aws_iam_role.ec2_role[0].name
  policy_arn = var.iam_role_policies[count.index]
}

# Attach CloudWatch agent policy
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  count = var.create_iam_instance_profile && var.enable_detailed_monitoring ? 1 : 0

  role       = aws_iam_role.ec2_role[0].name
  policy_arn = aws_iam_policy.cloudwatch_agent[0].arn
}

# Attach SSM managed policy
resource "aws_iam_role_policy_attachment" "ssm_managed" {
  count = var.create_iam_instance_profile && var.enable_ssm_managed ? 1 : 0

  role       = aws_iam_role.ec2_role[0].name
  policy_arn = aws_iam_policy.ssm_managed[0].arn
}

# Attach AWS managed SSM policy
resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  count = var.create_iam_instance_profile && var.enable_ssm_managed ? 1 : 0

  role       = aws_iam_role.ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  count = var.create_iam_instance_profile ? 1 : 0

  name = "${var.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2_role[0].name

  tags = local.module_tags
}

# -----------------------------------------------------------------------------
# EC2 Instances with Enhanced Security and Monitoring
# -----------------------------------------------------------------------------

resource "aws_instance" "main" {
  count = var.instance_count

  ami           = local.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Network configuration
  subnet_id                   = local.instance_subnets[count.index]
  vpc_security_group_ids      = var.vpc_security_group_ids
  associate_public_ip_address = var.associate_public_ip_address

  # Security enhancements
  source_dest_check = var.source_dest_check

  # Storage configuration
  ebs_optimized = var.ebs_optimized

  # Root block device with enhanced security
  root_block_device {
    volume_type           = var.root_block_device.volume_type
    volume_size           = var.root_block_device.volume_size
    delete_on_termination = var.root_block_device.delete_on_termination
    encrypted             = true # Force encryption for security
    iops                  = var.root_block_device.iops
    throughput            = var.root_block_device.throughput
    kms_key_id            = var.root_block_device.kms_key_id != null ? var.root_block_device.kms_key_id : data.aws_kms_key.ebs[0].arn

    tags = merge(
      local.module_tags,
      {
        Name           = "${var.name_prefix}-root-volume-${count.index + 1}"
        VolumeType     = "Root"
        BackupRequired = var.enable_backup ? "true" : "false"
      }
    )
  }

  # Additional EBS block devices with enhanced configuration
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      device_name           = ebs_block_device.value.device_name
      volume_type           = ebs_block_device.value.volume_type
      volume_size           = ebs_block_device.value.volume_size
      delete_on_termination = ebs_block_device.value.delete_on_termination
      encrypted             = true # Force encryption
      iops                  = ebs_block_device.value.iops
      throughput            = ebs_block_device.value.throughput
      kms_key_id            = ebs_block_device.value.kms_key_id != null ? ebs_block_device.value.kms_key_id : data.aws_kms_key.ebs[0].arn
      snapshot_id           = ebs_block_device.value.snapshot_id

      tags = merge(
        local.module_tags,
        {
          Name           = "${var.name_prefix}-${ebs_block_device.value.device_name}-${count.index + 1}"
          VolumeType     = "Additional"
          BackupRequired = var.enable_backup ? "true" : "false"
        }
      )
    }
  }

  # Metadata options for enhanced security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Force IMDSv2
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # Instance configuration
  user_data_base64                     = var.user_data != null ? base64encode(var.user_data) : null
  user_data_replace_on_change          = var.user_data_replace_on_change
  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  monitoring                           = var.enable_detailed_monitoring
  tenancy                              = var.placement_tenancy

  # IAM instance profile
  iam_instance_profile = var.iam_instance_profile != null ? var.iam_instance_profile : (
    var.create_iam_instance_profile ? aws_iam_instance_profile.ec2_profile[0].name : null
  )

  # Credit specification for burstable instances
  dynamic "credit_specification" {
    for_each = can(regex("^t[2-4]", var.instance_type)) ? [1] : []
    content {
      cpu_credits = var.cpu_credits
    }
  }

  # Lifecycle configuration
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      ami, # Ignore AMI changes to prevent accidental replacements
      user_data_base64
    ]
  }

  tags = merge(
    local.module_tags,
    {
      Name              = "${var.name_prefix}-instance-${count.index + 1}"
      InstanceType      = var.instance_type
      Environment       = var.environment
      BackupRequired    = var.enable_backup ? "true" : "false"
      MonitoringEnabled = var.enable_detailed_monitoring ? "true" : "false"
      SSMManaged        = var.enable_ssm_managed ? "true" : "false"
    }
  )

  volume_tags = merge(
    local.module_tags,
    {
      Name           = "${var.name_prefix}-volume-${count.index + 1}"
      BackupRequired = var.enable_backup ? "true" : "false"
    }
  )
}

# -----------------------------------------------------------------------------
# Elastic IPs (Optional)
# -----------------------------------------------------------------------------

resource "aws_eip" "main" {
  count = var.create_eip ? var.instance_count : 0

  instance = aws_instance.main[count.index].id
  domain   = "vpc"

  depends_on = [aws_instance.main]

  tags = merge(
    local.module_tags,
    {
      Name = "${var.name_prefix}-eip-${count.index + 1}"
    }
  )
}

# -----------------------------------------------------------------------------
# CloudWatch Alarms for Monitoring
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count = var.enable_detailed_monitoring ? var.instance_count : 0

  alarm_name          = "${var.name_prefix}-cpu-utilization-${count.index + 1}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    InstanceId = aws_instance.main[count.index].id
  }

  tags = local.module_tags
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  count = var.enable_detailed_monitoring ? var.instance_count : 0

  alarm_name          = "${var.name_prefix}-status-check-failed-${count.index + 1}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_description   = "This metric monitors ec2 status check"
  alarm_actions       = var.alarm_actions

  dimensions = {
    InstanceId = aws_instance.main[count.index].id
  }

  tags = local.module_tags
}

# -----------------------------------------------------------------------------
# AWS Backup Plan for Disaster Recovery
# -----------------------------------------------------------------------------

resource "aws_backup_vault" "main" {
  count = var.enable_backup ? 1 : 0

  name        = "${var.name_prefix}-backup-vault"
  kms_key_arn = var.backup_vault_kms_key_arn

  tags = merge(
    local.module_tags,
    {
      Name = "${var.name_prefix}-backup-vault"
    }
  )
}

resource "aws_backup_plan" "main" {
  count = var.enable_backup ? 1 : 0

  name = "${var.name_prefix}-backup-plan"

  rule {
    rule_name         = "daily_backup"
    target_vault_name = aws_backup_vault.main[0].name
    schedule          = var.backup_schedule

    lifecycle {
      cold_storage_after = 30
      delete_after       = var.backup_retention_days
    }

    recovery_point_tags = merge(
      local.module_tags,
      {
        BackupType = "Daily"
      }
    )
  }

  advanced_backup_setting {
    backup_options = {
      WindowsVSS = "enabled"
    }
    resource_type = "EC2"
  }

  tags = local.module_tags
}

# IAM role for AWS Backup
resource "aws_iam_role" "backup_role" {
  count = var.enable_backup ? 1 : 0

  name = "${var.name_prefix}-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "backup.amazonaws.com"
        }
      }
    ]
  })

  tags = local.module_tags
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  count = var.enable_backup ? 1 : 0

  role       = aws_iam_role.backup_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_backup_selection" "main" {
  count = var.enable_backup ? 1 : 0

  iam_role_arn = aws_iam_role.backup_role[0].arn
  name         = "${var.name_prefix}-backup-selection"
  plan_id      = aws_backup_plan.main[0].id

  resources = [for instance in aws_instance.main : instance.arn]

  condition {
    string_equals {
      key   = "aws:ResourceTag/BackupRequired"
      value = "true"
    }
  }
}

# -----------------------------------------------------------------------------
# CloudWatch Log Group for Instance Logs
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "instance_logs" {
  count = var.enable_detailed_monitoring ? 1 : 0

  name              = "/aws/ec2/${var.name_prefix}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.cloudwatch_logs_kms_key_arn

  tags = merge(
    local.module_tags,
    {
      Name = "${var.name_prefix}-instance-logs"
    }
  )
}
