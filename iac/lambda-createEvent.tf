
# Archivo ZIP para la función Lambda
data "archive_file" "lambda_create_event" {
  type        = "zip"
  source_dir  = "${path.module}/../createEvent"
  output_path = "${path.module}/bin/createEvent.zip"
}

resource "aws_lambda_function" "create_event" {
  function_name    = var.lambda_function_name_create_event
  filename         = data.archive_file.lambda_create_event.output_path
  source_code_hash = data.archive_file.lambda_create_event.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_exec_role.arn

  vpc_config {
    subnet_ids         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }


  environment {
    variables = {
      STAGE     = var.environment
      DB_HOST   = aws_db_instance.postgres_db.endpoint
      DB_NAME   = aws_db_instance.postgres_db.db_name
      DB_USER   = var.db_username
      DB_PASS   = var.db_password
    }

  }

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq_create_event.arn
  }

  tracing_config {
    mode = "Active"
  }
}

resource "aws_kms_key" "lambda_dlq_kms" {
  description             = "KMS Key for Lambda DLQ encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "lambda-dlq-kms-policy",
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
        Sid    = "AllowLambdaRoleToUseKMS",
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

resource "aws_sqs_queue" "lambda_dlq_create_event" {
  name              = "lambda-create-event-dlq"
  kms_master_key_id = aws_kms_key.lambda_dlq_kms.arn
}
