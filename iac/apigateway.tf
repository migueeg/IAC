# API Gateway
resource "aws_api_gateway_rest_api" "main" {
  name        = "eventos-api"
  description = "API para eventos"
}

# Recursos
resource "aws_api_gateway_resource" "login" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "login"
}

resource "aws_api_gateway_resource" "eventos" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "eventos"
}

resource "aws_api_gateway_resource" "register_event" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "register"
}

# Métodos POST
resource "aws_api_gateway_method" "login_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.login.id
  http_method   = "POST"
  authorization = "NONE"

  # Validación de solicitud
  request_validator_id = aws_api_gateway_request_validator.validate_body_and_params.id
}

resource "aws_api_gateway_method" "eventos_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.eventos.id
  http_method   = "POST"
  authorization = "NONE"

  #  Validación de solicitud
  request_validator_id = aws_api_gateway_request_validator.validate_body_and_params.id
}

resource "aws_api_gateway_method" "post_register_event" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.register_event.id
  http_method   = "POST"
  authorization = "NONE"

  #  Validación de solicitud
  request_validator_id = aws_api_gateway_request_validator.validate_body_and_params.id
}

# Integraciones Lambda
resource "aws_api_gateway_integration" "login_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.login.id
  http_method             = aws_api_gateway_method.login_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.login_user.invoke_arn
}

resource "aws_api_gateway_integration" "eventos_integration" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.eventos.id
  http_method             = aws_api_gateway_method.eventos_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_event.invoke_arn
}

resource "aws_api_gateway_integration" "register_event" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.register_event.id
  http_method             = aws_api_gateway_method.post_register_event.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.register_event.invoke_arn
}

# Deployment y stage
resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  
  depends_on = [
    aws_api_gateway_integration.login_integration,
    aws_api_gateway_integration.eventos_integration,
    aws_api_gateway_integration.register_event
  ]
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.environment

  # Habilitar X-Ray tracing (solución CKV_AWS_73)
  xray_tracing_enabled = true
}

#  Validación de solicitudes (nuevo recurso)
resource "aws_api_gateway_request_validator" "validate_body_and_params" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  name        = "validate-body-and-params"
  validate_request_body       = true
  validate_request_parameters = true
}

# Permisos Lambda para invocación desde API Gateway
resource "aws_lambda_permission" "api_gateway_login" {
  statement_id  = "AllowAPIGatewayInvokeLogin"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.login_user.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_eventos" {
  statement_id  = "AllowAPIGatewayInvokeEventos"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_event.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_register_event" {
  statement_id  = "AllowExecutionFromAPIGatewayRegisterEvent"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.register_event.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/POST/register"
}
