locals {
  vpc_id = [
    var.vpc_id,
    aws_vpc.main.id
    ]
}