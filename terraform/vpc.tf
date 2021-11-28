module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "mc-vpc"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  public_subnets  = [var.public_subnet_cidr]
}

data "aws_availability_zones" "available" {
  state = "available"
}