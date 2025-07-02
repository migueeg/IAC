resource "aws_lambda_function" "sqs_ses_consumer" {
  # checkov:skip=CKV_AWS_272 Code signing unnecessary for local testing environment
  # checkov:skip=CKV_AWS_116 Dead Letter Queue unnecessary for local testing environment
  # checkov:skip=CKV_AWS_50 X-Ray tracing unnecessary for local testing environment
  # checkov:skip=CKV_AWS_173 Environment variable encryption unnecessary for local testing
  # checkov:skip=CKV_AWS_117 VPC unnecessary for SQS/SES consumer function
  # checkov:skip=CKV_AWS_115 Concurrent execution limits unnecessary for local testing environment
  function_name = "lambda-sqs-ses-consumer"
  filename      = "${path.module}/bin/sqsSesConsumer.zip"
  source_code_hash = filebase64sha256("${path.module}/bin/sqsSesConsumer.zip")
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      EMAIL_FROM = "govench6@gmail.com"
      EMAIL_TO   = "govench6@gmail.com"
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.event_queue.arn
  function_name    = aws_lambda_function.sqs_ses_consumer.arn
  batch_size       = 1
  enabled          = true
}