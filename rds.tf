resource "aws_db_subnet_group" "rds" {
  name = "fms_rds_group"

  subnet_ids = [
    "${aws_subnet.fms.id}",
    "${aws_subnet.fms_az2.id}",
  ]

  tags {
    Name = "rds-subnet-group-${local.naming_suffix}"
  }
}

resource "aws_subnet" "fms_az2" {
  vpc_id                  = "${var.appsvpc_id}"
  cidr_block              = "${var.fms_cidr_block_az2}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.az2}"

  tags {
    Name = "az2-subnet-${local.naming_suffix}"
  }
}

resource "aws_route_table_association" "fms_rt_rds" {
  subnet_id      = "${aws_subnet.fms_az2.id}"
  route_table_id = "${var.route_table_id}"
}

resource "random_string" "password" {
  length  = 16
  special = false
}

resource "random_string" "username" {
  length  = 8
  special = false
  number  = false
}

resource "aws_security_group" "fms_db" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "sg-db-${local.naming_suffix}"
  }
}

resource "aws_security_group_rule" "allow_bastion" {
  type        = "ingress"
  description = "Postgres from the Bastion host"
  from_port   = "${var.rds_from_port}"
  to_port     = "${var.rds_to_port}"
  protocol    = "${var.rds_protocol}"

  cidr_blocks = [
    "${var.opssubnet_cidr_block}",
    "${var.peering_cidr_block}",
  ]

  security_group_id = "${aws_security_group.fms_db.id}"
}

resource "aws_security_group_rule" "allow_db_lambda" {
  type        = "ingress"
  description = "Postgres from the Lambda subnet"
  from_port   = "${var.rds_from_port}"
  to_port     = "${var.rds_to_port}"
  protocol    = "${var.rds_protocol}"

  cidr_blocks = [
    "${var.dq_lambda_subnet_cidr}",
    "${var.dq_lambda_subnet_cidr_az2}",
  ]

  security_group_id = "${aws_security_group.fms_db.id}"
}

resource "aws_security_group_rule" "allow_db_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.fms_db.id}"
}

resource "aws_db_instance" "postgres" {
  identifier                      = "fms-postgres-${local.naming_suffix}"
  allocated_storage               = 50
  storage_type                    = "gp2"
  engine                          = "postgres"
  engine_version                  = "10.6"
  instance_class                  = "db.m5.large"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  name                            = "${var.database_name}"
  port                            = "${var.port}"
  username                        = "${random_string.username.result}"
  password                        = "${random_string.password.result}"
  backup_window                   = "00:00-01:00"
  maintenance_window              = "tue:09:00-tue:10:00"
  backup_retention_period         = 14
  deletion_protection             = true
  storage_encrypted               = true
  multi_az                        = true
  skip_final_snapshot             = true
  ca_cert_identifier              = "${var.environment == "prod" ? "rds-ca-2015" : "rds-ca-2019"}"

  monitoring_interval = "60"
  monitoring_role_arn = "${var.rds_enhanced_monitoring_role}"

  db_subnet_group_name   = "${aws_db_subnet_group.rds.id}"
  vpc_security_group_ids = ["${aws_security_group.fms_db.id}"]

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name = "postgres-${local.naming_suffix}"
  }
}

module "rds_alarms" {
  source = "github.com/UKHomeOffice/dq-tf-cloudwatch-rds"

  naming_suffix                = "${local.naming_suffix}"
  environment                  = "${var.naming_suffix}"
  pipeline_name                = "FMS"
  db_instance_id               = "${aws_db_instance.postgres.id}"
  free_storage_space_threshold = 13000000000 # 13GB free space
  read_latency_threshold       = 0.1         # 100 milliseconds
  write_latency_threshold      = 0.35        # 350 milliseconds
}

resource "aws_ssm_parameter" "rds_fms_username" {
  name        = "rds_fms_username"
  type        = "SecureString"
  description = "FMS RDS master username"
  value       = "${random_string.username.result}"
}

resource "aws_ssm_parameter" "rds_fms_password" {
  name        = "rds_fms_password"
  type        = "SecureString"
  description = "FMS RDS master password"
  value       = "${random_string.password.result}"
}

resource "random_string" "service_username" {
  length  = 8
  special = false
  number  = false
}

resource "random_string" "service_password" {
  length  = 16
  special = false
}

resource "aws_ssm_parameter" "rds_fms_service_username" {
  name        = "rds_fms_service_username"
  type        = "SecureString"
  description = "FMS RDS read_only username"
  value       = "${random_string.service_username.result}"
}

resource "aws_ssm_parameter" "rds_fms_service_password" {
  name        = "rds_fms_service_password"
  type        = "SecureString"
  description = "FMS RDS read_only password"
  value       = "${random_string.service_password.result}"
}
