# ✅ S3 버킷 생성 (Terraform State 저장소)
resource "aws_s3_bucket" "terraform_state" {
  bucket = "ojang-terraform-state"  # ✅ 고유한 S3 버킷 이름 (팀원들이 동일하게 사용)

  # lifecycle {
  #   prevent_destroy = true  # ✅ 실수로 삭제되는 것을 방지
  # }
}

# ✅ S3 버킷 암호화 설정
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ✅ S3 버킷 퍼블릭 액세스 차단
resource "aws_s3_bucket_public_access_block" "s3_public_block" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ✅ DynamoDB 테이블 생성 (Terraform State Locking)
# resource "aws_dynamodb_table" "terraform_lock" {
#   name         = "terraform-lock"
#   billing_mode = "PAY_PER_REQUEST"
#   hash_key     = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }
# }

terraform {
  backend "s3" {
    bucket         = "ojang-terraform-state"  # ✅ S3에 상태 저장
    key            = "terraform.tfstate"  # ✅ 저장할 state 파일 이름
    region         = "ap-northeast-2"  # ✅ 서울 리전
    encrypt        = true  # ✅ 데이터 암호화
    # dynamodb_table = "terraform-lock"  # ✅ DynamoDB를 사용한 Locking (충돌 방지)
  }
}

