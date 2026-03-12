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
  for_each = {
    subnet_a = aws_subnet.receipt_corrector_subnets["public_a"].id
    subnet_b = aws_subnet.receipt_corrector_subnets["public_b"].id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.receipt_corrector_public.id
}