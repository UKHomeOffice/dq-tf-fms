variable "appsvpc_id" {
}

variable "opssubnet_cidr_block" {
}

variable "fms_cidr_block" {
}

variable "peering_cidr_block" {
}

variable "az" {
}

variable "az2" {
}

variable "fms_cidr_block_az2" {
}

variable "naming_suffix" {
  default     = false
  description = "Naming suffix for tags, value passed from dq-tf-apps"
}

variable "database_name" {
  default     = "fms"
  description = "RDS Postgres database name"
}

variable "port" {
  default     = "5432"
  description = "RDS Postgres port access"
}

variable "route_table_id" {
  default     = false
  description = "Value obtained from Apps module"
}

variable "rds_from_port" {
  default     = 5432
  description = "From port for Postgres traffic"
}

variable "rds_to_port" {
  default     = 5432
  description = "To port for Postgres traffic"
}

variable "rds_protocol" {
  default     = "tcp"
  description = "Protocol for Postgres traffic"
}

variable "dq_lambda_subnet_cidr" {
  default     = "10.1.42.0/24"
  description = "Dedicated subnet for Lambda ENIs"
}

variable "dq_lambda_subnet_cidr_az2" {
  default     = "10.1.43.0/24"
  description = "Dedicated subnet for Lambda ENIs"
}

variable "rds_enhanced_monitoring_role" {
  description = "ARN of the RDS enhanced monitoring role"
}

variable "environment" {
  default     = "notprod"
  description = "Switch between environments"
}

