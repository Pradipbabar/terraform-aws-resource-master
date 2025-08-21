resource "aws_sns_topic" "main" {
  name = "${var.name_prefix}-topic"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-topic"
    }
  )
}
