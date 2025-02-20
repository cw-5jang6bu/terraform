resource "aws_lambda_function" "lambda_redis" {
  function_name    = "lambda-redis-connector"
  role            = aws_iam_role.lambda_role.arn
  handler        = "main.lambda_handler"  # main.py 안의 lambda_handler 함수 사용
  runtime        = "python3.8"
  timeout        = 10
  memory_size    = 256

  filename         = "lambda.zip"
  # source_code_hash = filebase64sha256("lambda.zip")

  vpc_config {
    subnet_ids         = var.private_subnet_ids  # ✅ Private Subnet에 배포
    security_group_ids = [var.lambda_sg_id]
  }

  environment {
    variables = {
      # 추가
      # REDIS_HOST = aws_elasticache_replication_group.redis.primary_endpoint_address
      # REDIS_HOST = var.cache_endpoint
      REDIS_PORT = "6379"
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_execution]
}

# ✅ Lambda IAM Role (VPC 내 서비스 실행 가능)
resource "aws_iam_role" "lambda_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}


# 추가
resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda_execution_policy"
  description = "Lambda 실행 및 Redis 접근 권한"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "elasticache:DescribeCacheClusters",
          "elasticache:Connect"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}


# ✅ Lambda 실행을 위한 IAM 정책 추가
# resource "aws_iam_role_policy_attachment" "lambda_execution" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }