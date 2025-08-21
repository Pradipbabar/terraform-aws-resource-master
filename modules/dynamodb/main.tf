resource "aws_dynamodb_table" "main" {
  name         = "${var.name_prefix}-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-table"
    }
  )
}
