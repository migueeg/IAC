variable "lambda_function_name_login_user" {
  description = "Nombre de la función Lambda para login de usuarios"
  default     = "lambda-login-user"
}

data "archive_file" "lambda_login_user" {
  type        = "zip"
  source_dir  = "${path.module}/../loginUser"
  output_path = "${path.module}/bin/loginUser.zip"
}

resource "aws_lambda_function" "login_user" {
  function_name    = var.lambda_function_name_login_user
  filename         = data.archive_file.lambda_login_user.output_path
  source_code_hash = data.archive_file.lambda_login_user.output_base64sha256
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  role             = aws_iam_role.lambda_exec_role.arn

  environment {
    variables = {
      STAGE = "dev"
    }
  }

}