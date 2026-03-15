# EC2

resource "aws_key_pair" "receipt_key" {
  key_name   = "receipt_key"
  public_key = file(var.ssh_key_path)
}

resource "aws_security_group" "public_server" {
  description = "Allows HTTP+TLS+SSH inbound traffic from corporate IP."
  vpc_id      = aws_vpc.receipt_corrector.id

  tags = {
    Project = var.project_tag
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.public_server.id
  cidr_ipv4         = var.corp_ip
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.public_server.id
  cidr_ipv4         = var.corp_ip
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.public_server.id
  cidr_ipv4         = var.corp_ip
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_5000" {
  security_group_id = aws_security_group.public_server.id
  cidr_ipv4         = var.corp_ip
  from_port         = 5000
  ip_protocol       = "tcp"
  to_port           = 5000
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.public_server.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ECS

resource "aws_security_group" "alb_sg" {
  name   = "receipt-corrector-alb-sg"
  vpc_id = aws_vpc.receipt_corrector.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.corp_ip]
  }

#  ingress {
#    from_port   = 443
#    to_port     = 443
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = var.project_tag
  }
}