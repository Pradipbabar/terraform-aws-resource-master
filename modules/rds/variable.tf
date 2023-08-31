variable "rds_port" {
  description = "value of the postgres port"
  default     = 5432
}

variable "rds_identifier" {
  description = "value of the postgres identifier"
  default     = "postgres"
}

variable "rds_allocated_storage" {
  description = "value of the postgres allocated storage"
  default     = 20
}

variable "rds_engine" {
  description = "value of the postgres engine"
  default     = "postgres"
}

variable "rds_engine_version" {
  description = "value of the postgres engine version"
  default     = "15.2"
}

variable "rds_storage_type" {
  description = "value of the postgres storage type"
  default     = "gp2"
}

variable "rds_multi_az" {
  description = "value of the postgres multi az"
  default     = "false"
}

variable "rds_public_access" {
  description = "value of the postgres public access"
  default     = "false"
}

variable "rds_instance_class" {
  description = "value of the postgres instance class"
  default     = "db.t3.micro"
}

variable "rds_database_name" {
  description = "value of the postgres database name"
  default     = "postgres"
}

variable "final_snapshot_identifier" {
  description = "value of the postgres final snapshot identifier"
  default     = "postgres-final-snapshot"
}

variable "subnet_ids" {
  description = "subnet ids for database subnet group"
  default = []
}

variable "environment" {
  description = "environment"
  default = "DEV"
}
variable "vpc_security_group_ids" {
  description = "vpc security group ids"
  default = []
}

variable "username" {
  description = "username"
  default = "admin"
}

variable "password" {
  description = "password"
  default = "admin"
}

variable "allow_major_version_upgrade" {
  description = "allow major upgreade"
  default = false
}

variable "auto_minor_version_upgrade" {
  description = "automatic minor version upgrade"
  default = false
}

variable "apply_immediately" {
    description = "apply immediately"
    default = false
}
variable "storage_encrypted" {
    description = "storage encrypted"
    default = false
}
variable "skip_final_snapshot" {
  description = "skip final snapshot"
  default = true
}

variable "db_subnet_group_name" {
  description = "subnet gruop for database"
  default = ""
}