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

resource "aws_instance" "instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.aws_key_pair_name
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  vpc_security_group_ids      = var.security_group_ids
  user_data                   = templatefile("${path.module}/ansible-pull.tpl", { ansible_host_name = var.ansible_host_name })
  iam_instance_profile        = var.instance_profile_name
  tags = {
    "Name"        = var.name
    "Description" = var.description
    "Minecraft"   = true
  }

  root_block_device {
    volume_size = var.disk_size
  }
}

