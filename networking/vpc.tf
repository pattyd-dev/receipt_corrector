resource "aws_vpc" "receipt_corrector" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Project = var.project_tag
  }
}
