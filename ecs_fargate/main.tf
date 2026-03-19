resource "aws_ecs_cluster" "receipt_corrector" {
  name = "receipt-corrector-cluster"

  tags = {
    Project = var.project_tag
  }
}

# =============================================================================
# IAM - TASK EXECUTION ROLE (allows ECS to pull from ECR and write to CloudWatch)
# =============================================================================

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "receipt-corrector-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# =============================================================================
# IAM - TASK ROLE (permissions your app itself needs at runtime)
# =============================================================================

resource "aws_iam_role" "ecs_task_role" {
  name = "receipt-corrector-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
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
        Resource = data.terraform_remote_state.uploader_data_stores.outputs.dynamo_table_arn
      },
    ]
  })
}

resource "aws_iam_policy" "ecs_s3_read_policy" {
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
        Resource = data.terraform_remote_state.uploader_data_stores.outputs.source_bucket_arn
      },
    ]
  })
}

resource "aws_iam_policy" "ecs_task_policy" {
  name        = "DynamoDBWriteAccessPolicy"
  description = "A policy that allows writing to a specific DynamoDB table"

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

resource "aws_iam_role_policy_attachment" "dynamodb_read" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.dynamodb_read_policy.arn
}

resource "aws_iam_role_policy_attachment" "dynamodb_write" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_read" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_s3_read_policy.arn
}

# =============================================================================
# CLOUDWATCH LOG GROUP
# =============================================================================

resource "aws_cloudwatch_log_group" "receipt_corrector" {
  name              = "/ecs/receipt-corrector"
  retention_in_days = 30

  tags = {
    Project = var.project_tag
  }
}

# =============================================================================
# TASK DEFINITION (placeholder image — GitHub Actions will update this)
# =============================================================================

resource "aws_ecs_task_definition" "receipt_corrector" {
  family                   = "receipt-corrector"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "receipt-corrector"
      image     = "amazon/amazon-ecs-sample"   # placeholder, GitHub Actions replaces this
      essential = true

      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.receipt_corrector.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Project = var.project_tag
  }
}

# =============================================================================
# SECURITY GROUPS
# =============================================================================

# ECS Task Security Group — only accepts traffic from the ALB
resource "aws_security_group" "ecs_sg" {
  name   = "receipt-corrector-ecs-sg"
  vpc_id = data.terraform_remote_state.networking.outputs.vpc_id

  # ALB health checks and forwarded traffic
  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.networking.outputs.ecs_alb_sg]
  }

  # Direct access from corporate IP
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["${var.corp_ip}"]
  }
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

# =============================================================================
# APPLICATION LOAD BALANCER
# =============================================================================

resource "aws_lb" "receipt_corrector" {
  name               = "receipt-corrector-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.terraform_remote_state.networking.outputs.ecs_alb_sg]
  subnets            = [
    data.terraform_remote_state.networking.outputs.public_subnet_a,
    data.terraform_remote_state.networking.outputs.public_subnet_b
  ]

  tags = {
    Project = var.project_tag
  }
}

resource "aws_lb_target_group" "receipt_corrector" {
  name        = "receipt-corrector-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id
  target_type = "ip"   # required for Fargate awsvpc networking

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
  }

  tags = {
    Project = var.project_tag
  }
}

resource "aws_lb_listener" "receipt_corrector" {
  load_balancer_arn = aws_lb.receipt_corrector.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.receipt_corrector.arn
  }
}

# =============================================================================
# ECS SERVICE
# =============================================================================

resource "aws_ecs_service" "receipt_corrector" {
  name            = "receipt-corrector-service"
  cluster         = aws_ecs_cluster.receipt_corrector.id
  task_definition = aws_ecs_task_definition.receipt_corrector.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets = [
    #  data.terraform_remote_state.networking.outputs.private_subnet_a,
    #  data.terraform_remote_state.networking.outputs.private_subnet_b
    data.terraform_remote_state.networking.outputs.public_subnet_a,
    data.terraform_remote_state.networking.outputs.public_subnet_b
    ]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.receipt_corrector.arn
    container_name   = "receipt-corrector"
    container_port   = 5000
  }

  depends_on = [
    aws_lb_listener.receipt_corrector,
    aws_iam_role_policy_attachment.ecs_task_execution_policy
  ]

  tags = {
    Project = var.project_tag
  }
}

# =============================================================================
# ROUTE 53
# =============================================================================

resource "aws_route53_record" "ecs_receipt_corrector" {
  zone_id = var.route_53_zone_id
  name    = "ecs-corrector.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.receipt_corrector.dns_name
    zone_id                = aws_lb.receipt_corrector.zone_id
    evaluate_target_health = true
  }
}
