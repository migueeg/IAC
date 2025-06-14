# API Gateway
resource "aws_api_gateway_rest_api" "main" {
  name        = "eventos-api"
  description = "API para eventos"

  lifecycle {
    create_before_destroy = true
  }
}

# Crear un validador de solicitud
resource "aws_api_gateway_request_validator" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  name        = "validate_body"
  
  # Validar cuerpo de la solicitud
  validate_request_body = true

  # Validar los parámetros de la solicitud (opcional)
  validate_request_parameters = false
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
  authorization = "AWS_IAM"  # Usamos AWS_IAM o "API_KEY"
  
  # Asociar el validador de solicitudes
  request_validator_id = aws_api_gateway_request_validator.main.id
}

resource "aws_api_gateway_method" "eventos_post" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.eventos.id
  http_method   = "POST"
  authorization = "AWS_IAM"  # Usamos AWS_IAM o "API_KEY"

  # Asociar el validador de solicitudes
  request_validator_id = aws_api_gateway_request_validator.main.id
}

resource "aws_api_gateway_method" "post_register_event" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  resource_id   = aws_api_gateway_resource.register_event.id
  http_method   = "POST"
  authorization = "AWS_IAM"  # Usamos AWS_IAM o "API_KEY"
  
  # Asociar el validador de solicitudes
  request_validator_id = aws_api_gateway_request_validator.main.id
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
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.environment

  xray_tracing_enabled = true
  cache_cluster_enabled = true
  cache_cluster_size    = "0.5"  

  method_settings {
    method_path            = "*/*"
    caching_enabled        = true
    cache_ttl_in_seconds   = 300
    cache_data_encrypted   = true
    logging_level          = "INFO"
    metrics_enabled        = true
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_access_logs.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
    })
  }
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
