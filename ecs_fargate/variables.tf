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

variable "route_53_zone_id" {
  type = string
}

variable "domain_name" {
  type    = string
  default = "example.com"
}

variable "corp_ip" {
  type = string
}