
data "archive_file" "lambda_login_user" {
  type        = "zip"
  source_dir  = "${path.module}/../loginUser"
  output_path = "${path.module}/bin/loginUser.zip"
}

resource "aws_lambda_function" "login_user" {
  filename         = data.archive_file.lambda_login_user.output_path
  function_name    = "lambda-login-user"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq_login_user.arn
  }


  source_code_hash = data.archive_file.lambda_login_user.output_base64sha256


  vpc_config {
    subnet_ids         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  kms_key_arn = aws_kms_key.lambda_env_kms.arn

  environment {
    variables = {
      DB_HOST = aws_db_instance.postgres_db.endpoint
      DB_NAME = aws_db_instance.postgres_db.db_name
      DB_USER = var.db_username
      DB_PASS = var.db_password
    }
  }

  tracing_config {
    mode = "Active"
  }
}

resource "aws_sqs_queue" "lambda_dlq_login_user" {
  name = "lambda-login-user-dlq"
}
