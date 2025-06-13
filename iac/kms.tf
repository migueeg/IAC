resource "aws_kms_key" "frontend_kms" {
  description             = "Clave KMS para objetos del frontend"
  enable_key_rotation     = true
  deletion_window_in_days = 10
}

resource "aws_kms_key" "lambda_environment_kms" {
  description             = "KMS key for Lambda environment variables"
  enable_key_rotation     = true
  deletion_window_in_days = 10
}
