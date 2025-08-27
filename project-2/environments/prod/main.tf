# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# ------------------------------------------------------------------------------
# MODULES
# ------------------------------------------------------------------------------

module "networking" {
  source = "../../modules/networking"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = "10.1.0.0/16"
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]
  availability_zones   = ["${var.aws_region}a", "${var.aws_region}b"]
}

module "database" {
  source = "../../modules/database"

  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.networking.vpc_id
  private_subnet_ids     = module.networking.private_subnet_ids
  db_security_group_id   = [module.networking.db_security_group_id]
  db_instance_class      = "db.t3.small"
  db_allocated_storage   = 50
  db_name                = "proddb"
  db_username            = "prodadmin"
  db_password            = var.db_password
}

module "compute" {
  source = "../../modules/compute"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  private_subnet_ids    = module.networking.private_subnet_ids
  web_security_group_id = module.networking.web_security_group_id
  instance_type         = "t3.small"
  min_size              = 2
  max_size              = 5
  desired_capacity      = 2
  db_endpoint           = module.database.db_endpoint
  db_name               = module.database.db_name
  db_username           = "prodadmin"
  db_password           = var.db_password
}