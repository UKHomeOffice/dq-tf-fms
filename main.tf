locals {
  naming_suffix = "fms-${var.naming_suffix}"
}

resource "aws_subnet" "fms" {
  vpc_id                  = var.appsvpc_id
  cidr_block              = var.fms_cidr_block
  map_public_ip_on_launch = false
  availability_zone       = var.az

  tags = {
    Name = "subnet-${local.naming_suffix}"
  }
}

resource "aws_route_table_association" "fms_rt_rds_az1" {
  subnet_id      = aws_subnet.fms.id
  route_table_id = var.route_table_id
}

