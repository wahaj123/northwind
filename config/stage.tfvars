project_name = "northwind"
environment  = "stage"
aws_region   = "us-east-2"

vpc = {
  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "stage"
  }
}

rds = {
  name                         = "northwind"
  db_name                      = "northwind"
  db_username                  = "northwind"
  db_password                  = "yZsq2na80p0w"
  db_instance_class            = "db.t3.micro"
  engine_version               = "16.6"
  allocated_storage            = 20
  max_allocated_storage        = 100
  storage_type                 = "gp3"
  storage_encrypted            = true
  publicly_accessible          = false
  multi_az                     = false
  backup_retention_period      = 0
  performance_insights_enabled = true
  apply_immediately            = true
  deletion_protection          = false
  skip_final_snapshot          = true
  tags = {
    Name = "northwind-db"
  }
}
compute = {
  instance_type      = "t3.micro"
  min_size           = 1
  max_size           = 3
  desired_capacity   = 1
  health_check_path  = "/"
  health_check_match = "200"

  tags = {
    Name = "northwind-web"
  }
}
