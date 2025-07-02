resource "aws_lambda_function" "kinesis_consumer" {
  function_name    = "lambda-kinesis-consumer"
  filename         = "${path.module}/bin/kinesisConsumer.zip"
  source_code_hash = filebase64sha256("${path.module}/bin/kinesisConsumer.zip")
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  role             = aws_iam_role.lambda_exec_role.arn

  reserved_concurrent_executions = 5

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