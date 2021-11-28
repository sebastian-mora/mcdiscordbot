module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "mc-vpc"
  cidr = var.vpc_cidr

  public_subnets  = [var.public_subnet_cidr]
}