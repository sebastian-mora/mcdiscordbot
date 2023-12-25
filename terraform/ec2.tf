resource "aws_key_pair" "deployer" {
  key_name   = "aws-dev"
  public_key = file("${path.module}/aws-dev.pub")
}

module "vanilla" {
  source                = "./modules/ec2"
  name                  = "vanilla"
  ansible_host_name     = "vanilla"
  instance_type         = "m5.large"
  description           = "Vanilla MC Version: 1.20.4"
  aws_key_pair_name     = aws_key_pair.deployer.key_name
  instance_profile_name = aws_iam_role.minecraft_server_role.name
  subnet_id             = module.vpc.public_subnets[0]
  security_group_ids    = [aws_security_group.mc_sg.id, aws_security_group.allow_ssh_public.id]
}

# module "chocolate" {
#   source                = "./modules/ec2"
#   name                  = "chocolate"
#   ansible_host_name     = "chocolate"
#   instance_type         = "m5a.xlarge"
#   disk_size             = 20 # 20GB
#   description           = "Chocolate MC Version: 1.4.3"
#   aws_key_pair_name     = aws_key_pair.deployer.key_name
#   instance_profile_name = aws_iam_role.minecraft_server_role.name
#   subnet_id             = module.vpc.public_subnets[0]
#   security_group_ids    = [aws_security_group.mc_sg.id, aws_security_group.allow_ssh_public.id]
# }

module "prodigium" {
  source                = "./modules/ec2"
  name                  = "prodigium"
  ansible_host_name     = "prodigium"
  instance_type         = "m5a.xlarge"
  disk_size             = 20 # 20GB
  description           = "Prodigium MC Version: 3.1.6"
  aws_key_pair_name     = aws_key_pair.deployer.key_name
  instance_profile_name = aws_iam_role.minecraft_server_role.name
  subnet_id             = module.vpc.public_subnets[0]
  security_group_ids    = [aws_security_group.mc_sg.id, aws_security_group.allow_ssh_public.id]
}
