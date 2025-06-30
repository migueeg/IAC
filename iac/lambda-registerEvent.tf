resource "aws_dynamodb_table" "tabla_eventos" {
  name         = "tabla_eventos"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_lambda_function" "register_event" {
  filename         = "${path.module}/bin/registerEvent.zip"
  function_name    = "register_event"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = filebase64sha256("${path.module}/bin/registerEvent.zip")

  environment {
    variables = {
      TABLE_NAME = "tabla_eventos"
    }
  }

  # Añadido para configurar Lambda dentro de la VPC
  vpc_config {
    subnet_ids         = [aws_subnet.private_a.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}
