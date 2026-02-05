variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_instance_class" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "allocated_storage" {
  type = number
}

variable "max_allocated_storage" {
  type = number
}

variable "storage_type" {
  type = string
}

variable "storage_encrypted" {
  type = bool
}

variable "publicly_accessible" {
  type = bool
}

variable "multi_az" {
  type = bool
}

variable "backup_retention_period" {
  type = number
}

variable "performance_insights_enabled" {
  type = bool
}

variable "apply_immediately" {
  type = bool
}

variable "deletion_protection" {
  type = bool
}

variable "skip_final_snapshot" {
  type = bool
}

variable "tags" {
  type    = map(string)
  default = {}
}
