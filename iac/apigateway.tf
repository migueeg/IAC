resource "aws_api_gateway_rest_api" "main" {
  name        = "eventAppApi"
  description = "API Gateway para funciones Lambda createEvent y loginUser"
}

# Recursos de ruta
resource "aws_api_gateway_resource" "create_event" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "createevent"
}

resource "aws_api_gateway_resource" "login_user" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "login"
}

# Métodos POST
resource "aws_api_gateway_method" "post_create_event" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.create_event.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "post_login_user" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.login_user.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integraciones Lambda
resource "aws_api_gateway_integration" "create_event" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.create_event.id
  http_method             = aws_api_gateway_method.post_create_event.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_event.invoke_arn
}

resource "aws_api_gateway_integration" "login_user" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.login_user.id
  http_method             = aws_api_gateway_method.post_login_user.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.login_user.invoke_arn
}

# Deployment y stage
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.create_event,
    aws_api_gateway_integration.login_user
  ]
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = "dev"
}

# Permisos Lambda para invocación desde API Gateway
resource "aws_lambda_permission" "api_gateway_create_event" {
  statement_id  = "AllowExecutionFromAPIGatewayCreateEvent"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_event.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/POST/createevent"
}

resource "aws_lambda_permission" "api_gateway_login_user" {
  statement_id  = "AllowExecutionFromAPIGatewayLoginUser"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.login_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/POST/login"
}