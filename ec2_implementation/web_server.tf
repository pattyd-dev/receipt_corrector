resource "aws_iam_role" "receipt_corrector_role" {
  name = "receipt_corrector_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "dynamodb_read_policy" {
  name        = "DynamoDBReadPolicy"
  description = "Allows read-only access to DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:DescribeTable"
        ]
        Effect   = "Allow"
        Resource = var.source_dynamo_arn
      },
    ]
  })
}

resource "aws_iam_policy" "s3_read_policy" {
  name        = "s3ReadPolicy"
  description = "Allows read-only access to s3 image bucket."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.image_bucket}/*"
      },
    ]
  })
}

resource "aws_iam_policy" "source_read_policy" {
  description = "Allows read-only access to s3 source code bucket."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.code_bucket}/*"
      },
    ]
  })
}

resource "aws_iam_policy" "dynamodb_write_policy" {
  name        = "DynamoDBWriteAccessPolicy"
  description = "A policy that allows an EC2 instance to write to a specific DynamoDB table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
            "dynamodb:PutItem",
            "dynamodb:BatchWriteItem",
            "dynamodb:UpdateItem",
            "dynamodb:DeleteItem",
            "dynamodb:BatchGetItem",
            "dynamodb:GetItem",
            "dynamodb:Query",
            "dynamodb:Scan"
        ]
        Effect   = "Allow"
        Resource = data.terraform_remote_state.data.outputs.dest_dynamo_arn
      },
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "attach_dynamo_read_policy" {
  role       = aws_iam_role.receipt_corrector_role.name
  policy_arn = aws_iam_policy.dynamodb_read_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_dynamo_write_policy" {
  role       = aws_iam_role.receipt_corrector_role.name
  policy_arn = aws_iam_policy.dynamodb_write_policy.arn
}


resource "aws_iam_role_policy_attachment" "attach_s3_read_policy" {
  role       = aws_iam_role.receipt_corrector_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}

resource "aws_iam_role_policy_attachment" "attach_s3_source_read_policy" {
  role       = aws_iam_role.receipt_corrector_role.name
  policy_arn = aws_iam_policy.source_read_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_read_profile"
  role = aws_iam_role.receipt_corrector_role.name
}


resource "aws_instance" "web_server" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.amazon_linux_server_ami.id
  key_name               = data.terraform_remote_state.networking.outputs.receipt_corrector_key_pair
  vpc_security_group_ids = [data.terraform_remote_state.networking.outputs.public_sg]
  subnet_id              = data.terraform_remote_state.networking.outputs.public_subnet
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  user_data     = file(var.user_data_path)

  root_block_device {
    volume_size = 8
  }

  tags = {
    Project = var.project_tag
  }

  provisioner "local-exec" {
    command = templatefile(var.ssh_config_path, {
      hostname     = self.public_ip,
      user         = var.ssh_user,
      identityfile = var.ssh_identity_path
    })

    interpreter = ["bash", "-c"]
  }
}

resource "aws_route53_record" "receipt_corrector" {
  zone_id = var.route_53_zone_id
  name    = "corrector.${var.domain_name}"
  type    = "A"
  ttl     = 300

  records = [aws_instance.web_server.public_ip]
}

