
module "vanilla" {
  source                = "./modules/ec2"
  name                  = "vanilla"
  ansible_host_name     = "vanilla"
  instance_type         = "m5.large"
  instance_profile_name = aws_iam_role.minecraft_server_role.name
  subnet_id             = module.vpc.public_subnets[0]
  security_group_ids    = [aws_security_group.mc_sg.id, aws_security_group.allow_ssh_public.id]
}

module "rlcraft" {
  source                = "./modules/ec2"
  name                  = "rlcraft"
  ansible_host_name     = "rlcraft"
  instance_type         = "m5.large"
  instance_profile_name = aws_iam_role.minecraft_server_role.name
  subnet_id             = module.vpc.public_subnets[0]
  security_group_ids    = [aws_security_group.mc_sg.id, aws_security_group.allow_ssh_public.id]
}