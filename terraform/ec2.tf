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
  public_key = file("resources/aws-dev.pub")
}

resource "aws_ebs_volume" "world-vol" {
  availability_zone = aws_instance.mc1.availability_zone
  size              = 10
  tags = {
    "Name" = "Vanilla"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.world-vol.id
  instance_id = aws_instance.mc1.id
}


resource "aws_instance" "mc1" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "m4.large"
  key_name                    = aws_key_pair.deployer.key_name
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  security_groups = [ aws_security_group.mc-sg.id, aws_security_group.allow-ssh-public.id ]
  user_data                   = data.template_file.ec2_install_script_mc.rendered
  iam_instance_profile        = aws_iam_instance_profile.test_profile.name
  tags = {
    "Name"        = "Vanilla"
    "Description" = "Vanilla Minecraft Server"
    "Minecraft"   = true
  }
}


resource "aws_security_group" "mc-sg" {
  description = "Allow mc connections"
  name        = "mc-sg"
  vpc_id = module.vpc.vpc_id
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
  vpc_id = module.vpc.vpc_id
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

data "template_file" "ec2_install_script_mc" {
  template = file("./resources/scripts/install.tpl")
    vars = {
      bucket = aws_s3_bucket.mc-worlds.id
      url = var.mc_server_url
    }
}