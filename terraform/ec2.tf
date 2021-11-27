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

resource "aws_ebs_volume" "vanilla_ebs" {
  availability_zone = "us-west-2a"
  size              = 10

  tags = {
    Name = "vanilla"
  }
}

resource "aws_volume_attachment" "vanilla_vol" {
 device_name = "/dev/sdc"
 volume_id = aws_ebs_volume.vanilla_ebs.id
 instance_id = aws_instance.mc1.id
}


resource "aws_instance" "mc1" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "m4.large"
  subnet_id = aws_subnet.mc_public.id
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.test_profile.name
}


resource "aws_security_group" "mc-sg" {
  description = "Allow mc connections"
  name = "mc-sg"

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