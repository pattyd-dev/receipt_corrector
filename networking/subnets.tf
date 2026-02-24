resource "aws_subnet" "receipt_public" {
  vpc_id                  = aws_vpc.receipt_corrector.id
  cidr_block              = var.public_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Project = var.project_tag
  }
}

resource "aws_subnet" "receipt_private" {
  vpc_id                  = aws_vpc.receipt_corrector.id
  cidr_block              = var.private_cidr
  map_public_ip_on_launch = false
  availability_zone       = "${var.aws_region}a"

  tags = {
    Project = var.project_tag
  }
}