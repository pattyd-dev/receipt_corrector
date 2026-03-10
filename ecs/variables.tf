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

variable "project_name" {
  type    = string
  default = "Receipt Corrector"
}
