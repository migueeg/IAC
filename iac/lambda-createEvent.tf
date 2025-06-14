# Archivo ZIP para la función Lambda
data "archive_file" "lambda_create_event" {
  type        = "zip"
  source_dir  = "${path.module}/../createEvent"
  output_path = "${path.module}/bin/createEvent.zip"
}

# Configuración de la función Lambda
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

  reserved_concurrent_executions = var.lambda_reserved_concurrency

  environment {
    variables = {
      STAGE     = var.environment
      DB_HOST   = aws_db_instance.postgres_db.endpoint
      DB_NAME   = aws_db_instance.postgres_db.db_name
      DB_USER   = var.db_username
      DB_PASS   = var.db_password
    }

    # Cifrado de las variables de entorno con la clave KMS
    kms_key_arn = aws_kms_key.lambda_environment_kms.arn
  }

  # Configuración de DLQ (Dead Letter Queue)
  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq.arn
  }

  # Validación de la firma del código
  code_signing_config_arn = aws_lambda_code_signing_config.create_event_code_signing.arn
  
  # Habilitar el trazado X-Ray
  tracing_config {
    mode = "Active"
  }
}

# Crear el Dead Letter Queue (DLQ)
resource "aws_sqs_queue" "lambda_dlq" {
  name = "lambda-dead-letter-queue"
}
