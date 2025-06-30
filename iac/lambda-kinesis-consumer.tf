resource "aws_lambda_function" "kinesis_consumer" {
  function_name    = "lambda-kinesis-consumer"
  filename         = "${path.module}/bin/kinesisConsumer.zip"
  source_code_hash = filebase64sha256("${path.module}/bin/kinesisConsumer.zip")
  handler          = "index.handler"
  runtime          = "nodejs18.x"  # Cambiado para evitar runtime obsoleto
  role             = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      STAGE = "dev"
    }
  }

  # Añadido para validar firma de código
  code_signing_config_arn = aws_lambda_code_signing_config.kinesis_code_signing.arn
}

resource "aws_lambda_event_source_mapping" "kinesis_lambda_trigger" {
  event_source_arn  = aws_kinesis_stream.event_stream.arn
  function_name     = aws_lambda_function.kinesis_consumer.arn
  starting_position = "LATEST"
  batch_size        = 1
  enabled           = true
}

# Code Signing Config
resource "aws_lambda_code_signing_config" "kinesis_code_signing" {
  allowed_publishers {
    signing_profile_version_arns = [
      "arn:aws:signer:us-east-1:123456789012:/signing-profiles/example-profile/EXAMPLE_VERSION"
    ]
  }

  policies {
    untrusted_artifact_on_deployment = "Enforce"
  }
}
