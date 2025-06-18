# Rol principal para Lambda
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Política con permisos para CloudWatch Logs y RDS
resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Permisos para CloudWatch Logs
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      # Permisos para EC2 Network Interfaces (para Lambda VPC)
      {
        Effect   = "Allow"
        Action   = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ]
        Resource = "*"
      },
      # Permiso para conectar con RDS
      {
        Effect   = "Allow"
        Action   = ["rds-db:connect"]
        Resource = aws_db_instance.postgres_db.arn
      }
    ]
  })
}

# Adjuntar la política al rol
resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Permitir que la Lambda acceda a DynamoDB
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Permitir que la Lambda acceda a SQS
resource "aws_iam_role_policy_attachment" "lambda_sqs_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

# Permitir que la Lambda acceda a SES (para enviar correos)
resource "aws_iam_role_policy_attachment" "lambda_ses_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

# Permitir que la Lambda acceda a Kinesis
resource "aws_iam_role_policy_attachment" "lambda_kinesis_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFullAccess"
}

# Obtener el ID de la cuenta AWS (para política KMS dinámica)
data "aws_caller_identity" "current" {}

# KMS Key para cifrado de variables de entorno y DynamoDB
resource "aws_kms_key" "lambda_env_kms" {
  description         = "KMS key para cifrado de variables de entorno y DynamoDB"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "lambda-env-key-policy",
    Statement = [
      {
        Sid    = "AllowRootAccess",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "AllowLambdaUsage",
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

# Permitir que S3 invoque la función Lambda
resource "aws_iam_role_policy_attachment" "lambda_s3_access" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
