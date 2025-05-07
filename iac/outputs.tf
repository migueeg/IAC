output "lambda_create_event_name" {
  value       = aws_lambda_function.create_event.function_name
  description = "Nombre de la función Lambda para crear eventos"
}

output "lambda_login_user_name" {
  value       = aws_lambda_function.login_user.function_name
  description = "Nombre de la función Lambda para login"
}

output "lambda_exec_role_arn" {
  value       = aws_iam_role.lambda_exec_role.arn
  description = "ARN del rol compartido de ejecución Lambda"
}

output "cloudfront_url" {
  description = "Dominio público para acceder al sitio web vía CloudFront"
  value       = "https://${aws_cloudfront_distribution.cdn.domain_name}"
}