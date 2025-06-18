variable "lambda_function_name_create_event" {
  description = "Nombre de la función Lambda para crear eventos"
  default     = "lambda-create-event"
}

variable "environment" {
  description = "Ambiente de desarrollo"
  default     = "dev"
}

variable "db_username" {
  description = "Usuario para PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Contraseña para PostgreSQL"
  type        = string
  sensitive   = true
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to connect to RDS"
  type        = list(string)
  default     = ["0.0.0.0/0"]   
}

variable "lambda_reserved_concurrency" {
  description = "Límite de concurrencia reservado para funciones Lambda"
  type        = number
  default     = 5
}

variable "code_signing_config_arn" {
  description = "ARN de la configuración de firma de código"
  type        = string
}

variable "lambda_subnet_ids" {
  type        = list(string)
  description = "Lista de Subnet para lambda kinesis consumer"
}
variable "lambda_security_group_ids" {
  type        = list(string)
  description = "Lista de IDs de grupos de seguridad para funciones Lambda kinesis consumer"
} 

variable "acm_certificate_arn" {
  description = "ARN del certificado SSL para cloudfront"
  type        = string
} 

