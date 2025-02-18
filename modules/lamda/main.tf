resource "aws_lambda_function" "lambda_redis" {
  function_name    = "lambda-redis-connector"
  role            = aws_iam_role.lambda_role.arn
  handler        = "main.lambda_handler"  # main.py 안의 lambda_handler 함수 사용
  runtime        = "python3.8"
  timeout        = 10
  memory_size    = 256

  filename         = "Lamda.zip"
  source_code_hash = filebase64sha256("Lamda.zip")

  vpc_config {
    subnet_ids         = var.private_subnet_ids  # ✅ Private Subnet에 배포
    security_group_ids = [var.lamda_sg_id]
  }

  environment {
    variables = {
      REDIS_HOST = var.cache_endpoint
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

# ✅ Lambda 실행을 위한 IAM 정책 추가
resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
