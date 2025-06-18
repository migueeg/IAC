resource "aws_lambda_function" "kinesis_consumer" {
  function_name    = "lambda-kinesis-consumer"
  filename         = "${path.module}/bin/kinesisConsumer.zip"
  source_code_hash = filebase64sha256("${path.module}/bin/kinesisConsumer.zip")
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  role             = aws_iam_role.lambda_exec_role.arn


  vpc_config {
    subnet_ids         = var.lambda_subnet_ids
    security_group_ids = var.lambda_security_group_ids
  }

  environment {
    variables = {
      STAGE = "dev"
    }
  }

  dead_letter_config {
    target_arn = aws_sqs_queue.lambda_dlq_kinesis_consumer.arn
  }

  tracing_config {
    mode = "Active"
  }
}

resource "aws_lambda_event_source_mapping" "kinesis_lambda_trigger" {
  event_source_arn  = aws_kinesis_stream.event_stream.arn
  function_name     = aws_lambda_function.kinesis_consumer.arn
  starting_position = "LATEST"
  batch_size        = 1
  enabled           = true
}

resource "aws_sqs_queue" "lambda_dlq_kinesis_consumer" {
  name = "lambda-kinesis-consumer-dlq"
}