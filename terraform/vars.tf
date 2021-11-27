variable "region" {
  default = "us-west-2"
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "172.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "172.0.10.0/24"
}

variable "alert-lambda-arn" {
  default = "arn:aws:lambda:us-west-2:621056530958:function:mcdiscordbot-dev-sendDiscordMessage"
}

variable "discord-webhook" {
  type = string
  sensitive=true
}

variable "rconpass" {
  type = string
  sensitive = true
}