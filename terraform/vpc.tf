module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "mc-vpc"
  cidr = var.vpc_cidr

  azs            = data.aws_availability_zones.available.names
  public_subnets = [var.public_subnet_cidr]
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_security_group" "mc_sg" {
  description = "Allow mc connections"
  name        = "mc-sg"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description      = "Allow MC Server"
    from_port        = 25565
    to_port          = 25565
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "allow_ssh_public" {
  description = "Allow mc connections"
  name        = "allow-ssh-public"
  vpc_id      = module.vpc.vpc_id
  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}
