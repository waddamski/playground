variable "region" {}
variable "aws_creds" {}
variable "profile" {}
variable "my_ami" {
  type = map(string)
}
variable "instance_type" {}


provider "aws" {
  region                  = var.region
  shared_credentials_file = var.aws_creds
  profile                 = var.profile
}

resource "aws_instance" "web" {
  ami = lookup(var.my_ami, var.region)
  instance_type = var.instance_type
  tags = {
    Name = "aw_terraweb"
  }
}
