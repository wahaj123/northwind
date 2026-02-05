locals {
  name = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  merged_vpc_tags     = merge(local.common_tags, var.vpc.tags)
  merged_rds_tags     = merge(local.common_tags, var.rds.tags)
  merged_compute_tags = merge(local.common_tags, var.compute.tags)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name               = var.vpc.name
  cidr               = var.vpc.cidr
  azs                = var.vpc.azs
  private_subnets    = var.vpc.private_subnets
  public_subnets     = var.vpc.public_subnets
  enable_nat_gateway = var.vpc.enable_nat_gateway
  enable_vpn_gateway = var.vpc.enable_vpn_gateway

  tags = local.merged_vpc_tags
}

module "rds" {
  source = "./module/rds"

  name               = var.rds.name
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = var.vpc.cidr
  private_subnet_ids = module.vpc.private_subnets

  db_name                      = var.rds.db_name
  db_username                  = var.rds.db_username
  db_password                  = var.rds.db_password
  db_instance_class            = var.rds.db_instance_class
  engine_version               = var.rds.engine_version
  allocated_storage            = var.rds.allocated_storage
  max_allocated_storage        = var.rds.max_allocated_storage
  storage_type                 = var.rds.storage_type
  storage_encrypted            = var.rds.storage_encrypted
  publicly_accessible          = var.rds.publicly_accessible
  multi_az                     = var.rds.multi_az
  backup_retention_period      = var.rds.backup_retention_period
  performance_insights_enabled = var.rds.performance_insights_enabled
  apply_immediately            = var.rds.apply_immediately
  deletion_protection          = var.rds.deletion_protection
  skip_final_snapshot          = var.rds.skip_final_snapshot

  tags = var.rds.tags
}


resource "aws_security_group" "alb_sg" {
  name        = "${local.name}-alb-sg"
  description = "ALB SG: allow HTTP from internet"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.merged_compute_tags, {
    Name = "${local.name}-alb-sg"
  })
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name               = "${local.name}-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb_sg.id]

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "web"
      }
    }
  }

  target_groups = {
    web = {
      name_prefix       = "web-"
      protocol          = "HTTP"
      port              = 80
      target_type       = "instance"
      create_attachment = false

      health_check = {
        enabled             = true
        path                = var.compute.health_check_path
        matcher             = var.compute.health_check_match
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
    }
  }

  tags = local.merged_compute_tags
}

module "compute" {
  source = "./module/compute"

  name                  = local.name
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnets
  alb_security_group_id = aws_security_group.alb_sg.id
  target_group_arn      = module.alb.target_groups["web"].arn

  instance_type    = var.compute.instance_type
  min_size         = var.compute.min_size
  max_size         = var.compute.max_size
  desired_capacity = var.compute.desired_capacity

  tags = local.merged_compute_tags
}
