output "vpc_id" {
  value       = aws_vpc.receipt_corrector.id
  description = "ID of main VPC."
}

output "public_subnet_a" {
  value       = aws_subnet.receipt_corrector_subnets["public_a"].id
  description = "Public subnet ID."
}

output "private_subnet_a" {
  value       = aws_subnet.receipt_corrector_subnets["private_a"].id
  description = "Private subnet ID."
}

output "public_subnet_b" {
  value       = aws_subnet.receipt_corrector_subnets["public_b"].id
  description = "Public subnet ID."
}

output "private_subnet_b" {
  value       = aws_subnet.receipt_corrector_subnets["private_b"].id
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

output "ecs_alb_sg" {
    value = aws_security_group.alb_sg.id
    description  = "Security Group for ALB in front of ECS cluster."
}