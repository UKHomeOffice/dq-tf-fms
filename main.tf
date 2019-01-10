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

resource "aws_security_group" "fms" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "sg-fms-${local.naming_suffix}"
  }

  ingress {
    from_port = 5432 
    to_port   = 5432 
    protocol  = "tcp"

    cidr_blocks = [
      #"${var.data_pipe_apps_cidr_block}",
      #"${var.opssubnet_cidr_block}",
      "${var.peering_cidr_block}"
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}
