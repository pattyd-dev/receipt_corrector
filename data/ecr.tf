resource "aws_ecr_repository" "receipt_corrector" {
  name                 = "receipt_corrector"
  image_tag_mutability = "MUTABLE"
  region = var.aws_region

  image_scanning_configuration {
    scan_on_push = true
  }
}
