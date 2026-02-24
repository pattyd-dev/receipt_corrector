# Copied directly from receipt_uploader, only changing the name. https://github.com/pattyd-dev/receipt_uploader

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