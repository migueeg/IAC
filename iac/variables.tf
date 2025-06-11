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
  default     = ["0.0.0.0/0"]  # Permite todas las IPs - solo para desarrollo
}

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