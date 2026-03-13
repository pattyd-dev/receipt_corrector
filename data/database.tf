resource "aws_dynamodb_table" "receipt_table_clean" {
  name         = var.dynamo_table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "documentId"

  attribute {
    name = "documentId"
    type = "S"
  }

  attribute {
    name = "dateOfPurchase"
    type = "S"
  }
  range_key = "dateOfPurchase"

  tags = {
    Project = var.project_name
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "receipt_data"
  engine               = "postgres"
  engine_version       = "17.9"
  instance_class       = "db.t3.micro"
  username = jsondecode(aws_secretsmanager_secret_version.db_password.secret_string)["username"]
  password = jsondecode(aws_secretsmanager_secret_version.db_password.secret_string)["password"]

  skip_final_snapshot  = true

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

# Generate a random password
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store it in Secrets Manager
resource "aws_secretsmanager_secret" "db_password" {
  name        = "receipt-corrector/db-password"
  description = "RDS master password for receipt corrector"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.db_password.result
  })
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [data.terraform_remote_state.networking.outputs.private_subnet_a, data.terraform_remote_state.networking.outputs.private_subnet_b]
}

resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = data.terraform_remote_state.networking.outputs.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.networking.outputs.public_sg]  # only allow your ECS tasks in
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}