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

variable "mc_server_url" {
  description = "JAR Url for mc version to download"'
  defdefault = "https://launcher.mojang.com/v1/objects/a16d67e5807f57fc4e550299cf20226194497dc2/server.jar"
}