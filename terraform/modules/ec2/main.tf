data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "deployer" {
  key_name   = "aws-dev"
  public_key = file("aws-dev.pub")
}


resource "aws_instance" "instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.mc-sg.id, aws_security_group.allow-ssh-public.id]
  user_data                   = data.template_file.ec2_ansible_pull_setup.rendered
  iam_instance_profile        = aws_iam_instance_profile.test_profile.arn
  tags = {
    "Name"        = var.name
    "Description" = var.description
    "Minecraft"   = true
  }
}


resource "aws_security_group" "mc-sg" {
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

resource "aws_security_group" "allow-ssh-public" {
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

data "template_file" "ec2_ansible_pull_setup" {
  template = file("./resources/ansible-pull.tpl")
  vars = {
    ansible_host_name = var.ansible_host_name // should match ansible/file.yml
  }
}
