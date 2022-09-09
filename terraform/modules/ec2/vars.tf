variable "name" {
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

