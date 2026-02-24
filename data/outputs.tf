output "dest_dynamo_arn" {
  value       = aws_dynamodb_table.receipt_table_clean.arn
  description = "Arn of destination dynamodb table."
}