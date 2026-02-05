variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc" {
  description = "VPC configuration"
  type = object({
    name               = string
    cidr               = string
    azs                = list(string)
    private_subnets    = list(string)
    public_subnets     = list(string)
    enable_nat_gateway = bool
    enable_vpn_gateway = bool
    tags               = map(string)
  })
}

variable "rds" {
  description = "RDS configuration"
  type = object({
    name                         = string
    db_name                      = string
    db_username                  = string
    db_password                  = string
    db_instance_class            = string
    engine_version               = string
    allocated_storage            = number
    max_allocated_storage        = number
    storage_type                 = string
    storage_encrypted            = bool
    publicly_accessible          = bool
    multi_az                     = bool
    backup_retention_period      = number
    performance_insights_enabled = bool
    apply_immediately            = bool
    deletion_protection          = bool
    skip_final_snapshot          = bool
    tags                         = map(string)
  })
  sensitive = true
}


variable "compute" {
  description = "Compute/ASG configuration"
  type = object({
    instance_type      = string
    min_size           = number
    max_size           = number
    desired_capacity   = number
    health_check_path  = string
    health_check_match = string
    tags               = map(string)
  })
}
