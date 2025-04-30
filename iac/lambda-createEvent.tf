variable "lambda_function_name_create_event" {
  description = "Nombre de la función Lambda para crear eventos"
  default     = "lambda-create-event"
}

data "archive_file" "lambda_create_event" {
  type        = "zip"
  source_dir  = "${path.module}/../createEvent"
  output_path = "${path.module}/bin/createEvent.zip"
}

resource "aws_lambda_function" "create_event" {
  function_name    = var.lambda_function_name_create_event
  filename         = data.archive_file.lambda_create_event.output_path
  source_code_hash = data.archive_file.lambda_create_event.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  role             = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      STAGE = "dev"
    }
  }

}