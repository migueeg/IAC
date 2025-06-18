
# Clave KMS para cifrado de la cola SQS (DLQ)
resource "aws_kms_key" "sqs_kms_key" {
  description = "KMS key for SQS DLQ encryption"
  enable_key_rotation = true

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowRootAccountFullAccess",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = "kms:*",
        Resource = "*"
      },
      {
        Sid = "AllowSQSUsage",
        Effect = "Allow",
        Principal = {
          Service = "sqs.amazonaws.com"
        },
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "sqs_kms_alias" {
  name          = "alias/sqs-dlq-kms"
  target_key_id = aws_kms_key.sqs_kms_key.key_id
}

resource "aws_sqs_queue" "lambda_dlq_sqs_ses" {
  name               = "lambda-sqs-ses-dlq"
  kms_master_key_id  = aws_kms_key.sqs_kms_key.arn
}

resource "aws_sqs_queue_policy" "lambda_dlq_policy" {
  queue_url = aws_sqs_queue.lambda_dlq_sqs_ses.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowLambdaDLQ",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action    = "sqs:SendMessage",
        Resource  = aws_sqs_queue.lambda_dlq_sqs_ses.arn
      }
    ]
  })
}

resource "aws_lambda_function" "sqs_ses_consumer" {
  function_name         = "lambda-sqs-ses-consumer"
  filename              = "${path.module}/bin/sqsSesConsumer.zip"
  source_code_hash      = filebase64sha256("${path.module}/bin/sqsSesConsumer.zip")
  handler               = "index.handler"
  runtime               = "nodejs20.x"
  role                  = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      EMAIL_FROM = "govench6@gmail.com"
      EMAIL_TO   = "govench6@gmail.com"
    }
  }

  tracing_config {
    mode = "PassThrough"
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq_sqs_ses.arn
  }

  vpc_config {
    subnet_ids         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_group_ids = [aws_default_security_group.default_deny_all.id]
  }

  depends_on = [
    aws_sqs_queue.lambda_dlq_sqs_ses,
    aws_sqs_queue_policy.lambda_dlq_policy
  ]
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.event_queue.arn
  function_name    = aws_lambda_function.sqs_ses_consumer.arn
  batch_size       = 1
  enabled          = true
}