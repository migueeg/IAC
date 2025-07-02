resource "aws_lambda_function" "kinesis_consumer" {
  # checkov:skip=CKV_AWS_272 Code signing unnecessary for local testing environment
  # checkov:skip=CKV_AWS_116 Dead Letter Queue unnecessary for local testing environment
  # checkov:skip=CKV_AWS_50 X-Ray tracing unnecessary for local testing environment
  # checkov:skip=CKV_AWS_173 Environment variable encryption unnecessary for local testing
  # checkov:skip=CKV_AWS_117 VPC unnecessary for Kinesis consumer function
  # checkov:skip=CKV_AWS_115 Concurrent execution limits unnecessary for local testing environment
  function_name    = "lambda-kinesis-consumer"
  filename         = "${path.module}/bin/kinesisConsumer.zip"
  source_code_hash = filebase64sha256("${path.module}/bin/kinesisConsumer.zip")
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      STAGE = "dev"
    }
  }
}

resource "aws_lambda_event_source_mapping" "kinesis_lambda_trigger" {
  event_source_arn  = aws_kinesis_stream.event_stream.arn
  function_name     = aws_lambda_function.kinesis_consumer.arn
  starting_position = "LATEST"
  batch_size        = 1
  enabled           = true
}