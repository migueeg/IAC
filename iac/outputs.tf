# Outputs para Lambdas
output "lambda_create_event_name" {
  value       = aws_lambda_function.create_event.function_name
  description = "Nombre de la función Lambda para crear eventos"
}

output "lambda_login_user_name" {
  value       = aws_lambda_function.login_user.function_name
  description = "Nombre de la función Lambda para login"
}

# Output para IAM
output "lambda_exec_role_arn" {
  value       = aws_iam_role.lambda_exec_role.arn
  description = "ARN del rol compartido de ejecución Lambda"
}

# Outputs para Frontend
output "cloudfront_url" {
  description = "Dominio público para acceder al sitio web vía CloudFront"
  value       = "https://${aws_cloudfront_distribution.cdn.domain_name}"
}

# Outputs para API Gateway
output "api_base_url" {
  description = "URL base del API Gateway"
  value       = aws_api_gateway_stage.api_stage.invoke_url
}

output "login_endpoint" {
  description = "Endpoint para login"
  value       = "${aws_api_gateway_stage.api_stage.invoke_url}/login"
}

output "create_event_endpoint" {
  description = "Endpoint para crear eventos"
  value       = "${aws_api_gateway_stage.api_stage.invoke_url}/eventos"
}

# Outputs para Base de Datos
output "db_endpoint" {
  description = "Endpoint de la base de datos PostgreSQL"
  value       = aws_db_instance.postgres_db.endpoint
  sensitive   = true
}

output "db_name" {
  description = "Nombre de la base de datos"
  value       = aws_db_instance.postgres_db.db_name
}