resource "aws_cloudwatch_log_group" "main" {
  name = "${var.name_prefix}-log-group"

  retention_in_days = 14

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-log-group"
    }
  )
}
