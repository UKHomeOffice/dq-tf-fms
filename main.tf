locals {
  naming_suffix = "fms-${var.naming_suffix}"
}

resource "aws_subnet" "fms" {
  vpc_id                  = "${var.appsvpc_id}"
  cidr_block              = "${var.fms_cidr_block}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.az}"

  tags {
    Name = "subnet-${local.naming_suffix}"
  }
}

resource "aws_route_table_association" "fms_rt_rds_az1" {
  subnet_id      = "${aws_subnet.fms.id}"
  route_table_id = "${var.route_table_id}"
}

resource "aws_security_group" "fms_sg" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "sg-${local.naming_suffix}"
  }
}

resource "aws_security_group_rule" "allow_lambda" {
  type        = "ingress"
  description = "Postgres from the Lambda subnet"
  from_port   = "${var.rds_from_port}"
  to_port     = "${var.rds_to_port}"
  protocol    = "${var.rds_protocol}"

  cidr_blocks = [
    "${var.dq_lambda_subnet_cidr}",
    "${var.dq_lambda_subnet_cidr_az2}",
  ]

  security_group_id = "${aws_security_group.fms_sg.id}"
}

resource "aws_security_group_rule" "allow_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.fms_sg.id}"
}
