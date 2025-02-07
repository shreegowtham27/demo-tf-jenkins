module "vpc" {
  source              = "./modules/vpc"
  vpc_name            = var.vpc_name
  cidr_block          = var.cidr_block
  availability_zones  = var.availability_zones
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "ecr" {
  source           = "./modules/ecr"
  repository_name = var.repository_name
}
