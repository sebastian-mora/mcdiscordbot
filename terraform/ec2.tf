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

resource "aws_instance" "vanilla" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "m5.large"
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.mc-sg.id]
  user_data                   = data.template_file.ec2_install_script_mc_vanilla.rendered
  iam_instance_profile        = aws_iam_instance_profile.minecraft_server.name
  tags = {
    "Name"        = "vanilla"
    "Description" = "Vanilla Minecraft Server"
    "Minecraft"   = true
  }
}

resource "aws_instance" "modded" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "m5.xlarge"
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.mc-sg.id]
  user_data                   = data.template_file.ec2_install_script_mc_mod.rendered
  iam_instance_profile        = aws_iam_instance_profile.minecraft_server.name
  tags = {
    "Name"        = "modded"
    "Description" = "Modded Minecraft Server"
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

data "template_file" "ec2_install_script_mc_vanilla" {
  template = file("./resources/scripts/install-vanilla.tpl")
  vars = {
    bucket      = aws_s3_bucket.mc-worlds.id
    rcon_release_url = var.rcon_release_url
    url         = var.mc_server_url
    server_name = "vanilla"
  }
}

data "template_file" "ec2_install_script_mc_mod" {
  template = file("./resources/scripts/install-modded.tpl")
  vars = {
    bucket      = aws_s3_bucket.mc-worlds.id
    rcon_release_url = var.rcon_release_url
    url         = "https://edge.forgecdn.net/files/3836/58/RAD-Serverpack-1.50.zip"
    server_name = "modded"
  }
}