module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "mc-vpc"
  cidr = var.vpc_cidr

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c", "us-west-2d"]
  public_subnets  = [var.public_subnet_cidr]
}