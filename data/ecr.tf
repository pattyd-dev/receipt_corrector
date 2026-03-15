resource "aws_ecr_repository" "receipt_corrector" {
  name                 = "receipt_corrector"
  image_tag_mutability = "MUTABLE"
  region = var.aws_region

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_user" "github_action_user" {
  name = "github_action_user"
}

resource "aws_iam_user_policy_attachment" "ecr_power_user" {
  user       = aws_iam_user.github_action_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_user_policy_attachment" "ecs_full_access" {
  user       = aws_iam_user.github_action_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_access_key" "github_action_user_key" {
  user = aws_iam_user.github_action_user.name
}

output "access_key_id" {
  value     = aws_iam_access_key.github_action_user_key.id
  sensitive = true
}

output "secret_access_key" {
  value     = aws_iam_access_key.github_action_user_key.secret
  sensitive = true
}