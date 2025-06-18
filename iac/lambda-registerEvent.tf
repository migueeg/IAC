resource "aws_dynamodb_table" "tabla_eventos" {
  name         = "tabla_eventos"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.lambda_env_kms.arn
  }

  attribute {
    name = "id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }
}

resource "aws_lambda_function" "register_event" {
  filename         = "${path.module}/bin/registerEvent.zip"
  function_name    = "register_event"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = filebase64sha256("${path.module}/bin/registerEvent.zip")


  #Conexión a la VPC
  vpc_config {
    subnet_ids         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq_register_event.arn
  }

  environment {
    variables = {
      TABLE_NAME = "tabla_eventos"
    }
  }

  tracing_config {
    mode = "PassThrough"
  }
}
