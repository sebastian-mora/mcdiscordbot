variable "name" {
  type = string
}

variable "instance_profile_name" {
  type = string
}
variable "instance_type" {
  type    = string
  default = "m5.large"
}


variable "aws_key_pair_name" {
  type    = string
  default = ""
}

variable "description" {
  type    = string
  default = "minecraft server"
}

variable "ansible_host_name" {
  type = string
}

variable "security_group_ids" {
  type = list(any)
}

variable "subnet_id" {
  type = string
}

