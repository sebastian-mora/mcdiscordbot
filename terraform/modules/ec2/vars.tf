variable "name" {
  type = string
}

variable "instance_role_arn" {
  type = string
}
variable "instance_type" {
  type    = string
  default = "m5.large"
}

variable "description" {
  type    = string
  default = "minecraft server"
}

variable "ansible_host_name" {
  type = string
}

variable "domain_name" {
  type    = string
  default = "mc.rusecrew.com"
}

variable "security_group_ids" {
  type = list(any)
}

variable "subnet_id" {
  type = string
}

