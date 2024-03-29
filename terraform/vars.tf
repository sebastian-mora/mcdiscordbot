variable "region" {
  default = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
  default     = "10.0.10.0/24"
}

variable "discord-webhook" {
  type      = string
  sensitive = true
}

variable "rconpass" {
  type      = string
  sensitive = true
}

variable "ssh_deploy_key" {
  type      = string
  sensitive = true
}
