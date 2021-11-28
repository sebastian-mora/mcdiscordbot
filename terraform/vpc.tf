module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "mc-vpc"
  cidr = var.vpc_cidr

  azs             = ["us-west-1a", "us-west-1b"]
  public_subnets  = [var.public_subnet_cidr]
}