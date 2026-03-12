variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_user" {
  type = string
}

variable "aws_credential_path" {
  type = string
}

variable "project_tag" {
  type    = string
  default = "Receipt Corrector"
}

variable "public_cidr_a" {
  type = string
}

variable "private_cidr_a" {
  type = string
}

variable "public_cidr_b" {
  type = string
}

variable "private_cidr_b" {
  type = string
}
variable "vpc_cidr" {
  type = string
}

variable "corp_ip" {
  type = string
}

variable "ssh_key_path" {
  type = string
}

