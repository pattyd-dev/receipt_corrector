output "vpc_id" {
  value       = aws_vpc.receipt_corrector.id
  description = "ID of main VPC."
}

output "public_subnet" {
  value       = aws_subnet.receipt_public.id
  description = "Public subnet ID."
}

output "private_subnet" {
  value       = aws_subnet.receipt_private.id
  description = "Private subnet ID."
}

output "public_sg" {
  value       = aws_security_group.public_server.id
  description = "Public security group ID."
}

output "receipt_corrector_key_pair" {
  value       = aws_key_pair.receipt_key.id
  description = "Key pair for SSH connection."
}