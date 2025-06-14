resource "aws_lambda_function" "sqs_ses_consumer" {
  function_name         = "lambda-sqs-ses-consumer"
  filename              = "${path.module}/bin/sqsSesConsumer.zip"
  source_code_hash      = filebase64sha256("${path.module}/bin/sqsSesConsumer.zip")
  handler               = "index.handler"
  runtime               = "nodejs20.x"  # Runtime actualizado
  role                  = aws_iam_role.lambda_exec_role.arn
  reserved_concurrent_executions = var.lambda_reserved_concurrency

  environment {
    variables = {
      EMAIL_FROM = "govench6@gmail.com"
      EMAIL_TO   = "govench6@gmail.com"
    }
  }

  tracing_config {
    mode = "PassThrough"
  }
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.event_queue.arn
  function_name    = aws_lambda_function.sqs_ses_consumer.arn
  batch_size       = 1
  enabled          = true
}
