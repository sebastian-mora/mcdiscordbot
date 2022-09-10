resource "aws_key_pair" "deployer" {
  key_name   = "aws-dev"
  public_key = file("${path.module}/aws-dev.pub")
}

module "vanilla" {
  source                = "./modules/ec2"
  name                  = "vanilla"
  ansible_host_name     = "vanilla"
  instance_type         = "m5.large"
  awsaws_key_pair_name  = aws_key_pair.deployer.key_name
  instance_profile_name = aws_iam_role.minecraft_server_role.name
  subnet_id             = module.vpc.public_subnets[0]
  security_group_ids    = [aws_security_group.mc_sg.id, aws_security_group.allow_ssh_public.id]
}

module "rlcraft" {
  source                = "./modules/ec2"
  name                  = "rlcraft"
  ansible_host_name     = "rlcraft"
  instance_type         = "m5.large"
  awsaws_key_pair_name  = aws_key_pair.deployer.key_name
  instance_profile_name = aws_iam_role.minecraft_server_role.name
  subnet_id             = module.vpc.public_subnets[0]
  security_group_ids    = [aws_security_group.mc_sg.id, aws_security_group.allow_ssh_public.id]
}