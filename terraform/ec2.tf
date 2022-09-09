
module "vanilla" {
  source = "./modules/ec2"
  name              = "vanilla"
  ansible_host_name = "vanilla"
}