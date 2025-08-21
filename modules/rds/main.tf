# -----------------------------------------------------------------------------
# RDS Instance - Enhanced with DR, Monitoring, and Security
# -----------------------------------------------------------------------------

resource "aws_db_instance" "main" {
  # Basic Configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  # Engine Configuration
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  parameter_group_name = var.parameter_group_name != null ? var.parameter_group_name : aws_db_parameter_group.main[0].name
  option_group_name    = var.option_group_name

  # Database Configuration
  identifier = var.identifier
  db_name    = var.database_name
  username   = var.username
  password   = var.password
  port       = var.port

  # Network Configuration
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids
  publicly_accessible    = var.publicly_accessible

  # High Availability & Disaster Recovery
  multi_az                = var.multi_az
  availability_zone       = var.multi_az ? null : var.availability_zone
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window
  copy_tags_to_snapshot   = true

  # Monitoring and Performance
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id       = var.performance_insights_kms_key_id
  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports

  # Security and Compliance
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.identifier}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Auto minor version upgrade
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # Storage IOPS
  iops = var.storage_type == "io1" || var.storage_type == "io2" ? var.iops : null

  # Character set for Oracle/SQL Server
  character_set_name = var.character_set_name
  timezone           = var.timezone

  # Apply changes immediately or during maintenance window
  apply_immediately = var.apply_immediately

  # Lifecycle management
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      password, # Ignore password changes to prevent accidental updates
    ]
  }

  tags = merge(
    var.common_tags,
    {
      Name               = var.identifier
      Module             = "rds"
      Engine             = var.engine
      MultiAZ            = var.multi_az
      BackupRetention    = var.backup_retention_period
      DeletionProtection = var.deletion_protection
      DataClassification = var.data_classification
    }
  )
}

# -----------------------------------------------------------------------------
# DB Parameter Group - Custom Configuration
# -----------------------------------------------------------------------------

resource "aws_db_parameter_group" "main" {
  count = var.parameter_group_name == null ? 1 : 0

  family = var.parameter_group_family
  name   = "${var.identifier}-params"

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.identifier}-params"
      Module = "rds"
    }
  )
}

# -----------------------------------------------------------------------------
# Enhanced Monitoring IAM Role
# -----------------------------------------------------------------------------

resource "aws_iam_role" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  name = "${var.identifier}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.identifier}-rds-monitoring-role"
      Module = "rds"
    }
  )
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.rds_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# -----------------------------------------------------------------------------
# Read Replica for Disaster Recovery
# -----------------------------------------------------------------------------

resource "aws_db_instance" "read_replica" {
  count = var.create_read_replica ? 1 : 0

  # Read replica configuration
  replicate_source_db = aws_db_instance.main.identifier
  identifier          = "${var.identifier}-read-replica"
  instance_class      = var.read_replica_instance_class != null ? var.read_replica_instance_class : var.instance_class

  # Override configurations for read replica
  publicly_accessible    = var.read_replica_publicly_accessible
  vpc_security_group_ids = var.read_replica_vpc_security_group_ids != null ? var.read_replica_vpc_security_group_ids : var.vpc_security_group_ids
  availability_zone      = var.read_replica_availability_zone

  # Monitoring
  monitoring_interval = var.read_replica_monitoring_interval
  monitoring_role_arn = var.read_replica_monitoring_interval > 0 ? aws_iam_role.rds_monitoring[0].arn : null

  # Performance Insights
  performance_insights_enabled = var.read_replica_performance_insights_enabled

  # No backup needed for read replica
  backup_retention_period = 0

  # Auto minor version upgrade
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  tags = merge(
    var.common_tags,
    {
      Name               = "${var.identifier}-read-replica"
      Module             = "rds"
      ReplicaOf          = aws_db_instance.main.identifier
      DataClassification = var.data_classification
    }
  )
}

# -----------------------------------------------------------------------------
# CloudWatch Alarms for Monitoring
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.identifier}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_utilization_threshold
  alarm_description   = "This metric monitors RDS CPU utilization"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  alarm_actions = var.alarm_sns_topic_arn != null ? [var.alarm_sns_topic_arn] : []

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.identifier}-cpu-alarm"
      Module = "rds"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "database_connections" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.identifier}-database-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.database_connections_threshold
  alarm_description   = "This metric monitors RDS database connections"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  alarm_actions = var.alarm_sns_topic_arn != null ? [var.alarm_sns_topic_arn] : []

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.identifier}-connections-alarm"
      Module = "rds"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "free_storage_space" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.identifier}-free-storage-space"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.free_storage_space_threshold
  alarm_description   = "This metric monitors RDS free storage space"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  alarm_actions = var.alarm_sns_topic_arn != null ? [var.alarm_sns_topic_arn] : []

  tags = merge(
    var.common_tags,
    {
      Name   = "${var.identifier}-storage-alarm"
      Module = "rds"
    }
  )
}
