# Identidad de la cuenta actual para políticas KMS
data "aws_caller_identity" "current" {}

# Configuración de claves KMS para las variables de entorno de Lambda
resource "aws_kms_key" "lambda_environment_kms" {
  description             = "KMS key for Lambda environment variables"
  enable_key_rotation     = true
  deletion_window_in_days = 10

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "key-default-1",
    Statement = [
      {
        Sid    = "AllowRootAccount",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "AllowLambdaUse",
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.lambda_exec_role.arn
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}

# Configuración de claves KMS para el frontend
resource "aws_kms_key" "frontend_kms" {
  description             = "Clave KMS para objetos del frontend"
  enable_key_rotation     = true
  deletion_window_in_days = 10

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "frontend-kms-policy",
    Statement = [
      {
        Sid    = "AllowRootAccountFrontend",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      }
    ]
  })
}

# Configuración de clave KMS personalizada para la cola SQS (event_queue)
resource "aws_kms_key" "sqs_event_kms" {
  description             = "CMK para cifrado de la SQS event_queue"
  enable_key_rotation     = true
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "sqs-kms-policy",
    Statement = [
      {
        Sid    = "AllowRootAccountSQS",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      }
    ]
  })
}
