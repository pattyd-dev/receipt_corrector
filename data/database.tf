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

# resource "aws_db_instance" "receipt_table_clean_rds" {
#   allocated_storage    = 10
#   db_name              = "mydb"
#   engine               = "mysql"
#   engine_version       = "8.0"
#   instance_class       = "db.t3.micro"
#   username             = "foo"
#   password             = "foobarbaz"
#   parameter_group_name = "default.mysql8.0"
#   skip_final_snapshot  = true
# }


# resource "aws_db_instance" "default" {
#   allocated_storage    = 10
#   db_name              = "mydb"
#   engine               = "postgres"
#   engine_version       = "16.3"
#   instance_class       = "db.t3.micro"
#   username             = "foo"
#   password             = "foobarbaz"
#   skip_final_snapshot  = true
# 
#   db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
#   vpc_security_group_ids = [aws_security_group.rds_sg.id]
# }
# 
# resource "aws_db_subnet_group" "rds_subnet_group" {
#   name       = "rds-subnet-group"
#   subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
# }
# 
# resource "aws_security_group" "rds_sg" {
#   name   = "rds-sg"
#   vpc_id = aws_vpc.main.id
# 
#   ingress {
#     from_port       = 5432
#     to_port         = 5432
#     protocol        = "tcp"
#     security_groups = [aws_security_group.ecs_sg.id]  # only allow your ECS tasks in
#   }
# 
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }