resource "aws_subnet" "receipt_corrector_subnets" {
  for_each = {
    public_a  = { cidr = var.public_cidr_a, az = "${var.aws_region}a", public = true  }
    private_a = { cidr = var.private_cidr_a, az = "${var.aws_region}a", public = false }
    public_b  = { cidr = var.public_cidr_b, az = "${var.aws_region}b", public = true  }
    private_b = { cidr = var.private_cidr_b, az = "${var.aws_region}b", public = false }
  }

  vpc_id                  = aws_vpc.receipt_corrector.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public

  tags = {
    Project = var.project_tag
  }
}