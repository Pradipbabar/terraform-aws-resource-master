# -----------------------------------------------------------------------------
# Local Values for EC2 Module
# -----------------------------------------------------------------------------

locals {
  # Common tags merged with module-specific tags
  module_tags = merge(
    var.common_tags,
    {
      Module = "ec2"
    }
  )

  # AMI ID selection with fallback to Amazon Linux 2
  ami_id = var.ami_id != null ? var.ami_id : (
    length(data.aws_ami.amazon_linux) > 0 ? data.aws_ami.amazon_linux[0].id : null
  )

  # Subnet ID selection with fallback to default VPC subnets
  subnet_ids = length(var.subnet_ids) > 0 ? var.subnet_ids : (
    length(data.aws_subnets.default) > 0 ? data.aws_subnets.default[0].ids : []
  )

  # Calculate instance subnet placement
  instance_subnets = [
    for i in range(var.instance_count) :
    local.subnet_ids[i % length(local.subnet_ids)]
  ]

  # Instance naming
  instance_names = [
    for i in range(var.instance_count) :
    "${var.name_prefix}-instance-${format("%02d", i + 1)}"
  ]

  # Volume naming
  volume_names = [
    for i in range(var.instance_count) :
    "${var.name_prefix}-volume-${format("%02d", i + 1)}"
  ]

  # EIP naming (if needed)
  eip_names = [
    for i in range(var.instance_count) :
    "${var.name_prefix}-eip-${format("%02d", i + 1)}"
  ]
}
