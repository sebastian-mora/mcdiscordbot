terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "ruse"

    workspaces {
      name = "mcdiscordbot"
    }
  }
}

provider "aws" {
  region = var.region
}