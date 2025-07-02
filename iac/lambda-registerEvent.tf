resource "aws_dynamodb_table" "tabla_eventos" {
  name         = "tabla_eventos"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  # Habilitar Point-in-Time Recovery para backups automáticos
  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_lambda_function" "register_event" {
  # checkov:skip=CKV_AWS_272 Code signing unnecessary for local testing environment
  # checkov:skip=CKV_AWS_116 Dead Letter Queue unnecessary for local testing environment
  # checkov:skip=CKV_AWS_50 X-Ray tracing unnecessary for local testing environment
  # checkov:skip=CKV_AWS_173 Environment variable encryption unnecessary for local testing
  # checkov:skip=CKV_AWS_117 VPC unnecessary for DynamoDB-only function
  # checkov:skip=CKV_AWS_115 Concurrent execution limits unnecessary for local testing environment
  filename         = "${path.module}/bin/registerEvent.zip"
  function_name    = "register_event"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = filebase64sha256("${path.module}/bin/registerEvent.zip")

  environment {
    variables = {
      TABLE_NAME = "tabla_eventos"
    }
  }
}
