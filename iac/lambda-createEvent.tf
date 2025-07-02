# Archivo ZIP para la función Lambda
data "archive_file" "lambda_create_event" {
  type        = "zip"
  source_dir  = "${path.module}/../createEvent"
  output_path = "${path.module}/bin/createEvent.zip"
}

resource "aws_lambda_function" "create_event" {
  # checkov:skip=CKV_AWS_272 Code signing unnecessary for local testing environment
  # checkov:skip=CKV_AWS_116 Dead Letter Queue unnecessary for local testing environment
  # checkov:skip=CKV_AWS_50 X-Ray tracing unnecessary for local testing environment
  # checkov:skip=CKV_AWS_173 Environment variable encryption unnecessary for local testing
  # checkov:skip=CKV_AWS_115 Concurrent execution limits unnecessary for local testing environment
  function_name    = var.lambda_function_name_create_event
  filename         = data.archive_file.lambda_create_event.output_path
  source_code_hash = data.archive_file.lambda_create_event.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  role            = aws_iam_role.lambda_exec_role.arn
  
  vpc_config {
    subnet_ids         = [aws_subnet.private_a.id]
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
}