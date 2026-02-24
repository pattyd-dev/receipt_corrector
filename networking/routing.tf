resource "aws_internet_gateway" "receipt_corrector" {
  vpc_id = aws_vpc.receipt_corrector.id

  tags = {
    Project = var.project_tag
  }
}

resource "aws_route_table" "receipt_corrector_public" {
  vpc_id = aws_vpc.receipt_corrector.id

  tags = {
    Project = var.project_tag
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.receipt_corrector_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.receipt_corrector.id
}

resource "aws_route_table_association" "receipt_corrector" {
  subnet_id      = aws_subnet.receipt_public.id
  route_table_id = aws_route_table.receipt_corrector_public.id
}