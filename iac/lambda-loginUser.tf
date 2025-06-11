# Configuración del paquete ZIP para la función Lambda
# Este bloque empaqueta el código fuente y sus dependencias
data "archive_file" "lambda_login_user" {
  type        = "zip"                           
  source_dir  = "${path.module}/../loginUser"  
  output_path = "${path.module}/bin/loginUser.zip" 
}

# Definición de la función Lambda
# Este recurso crea la función Lambda en AWS
resource "aws_lambda_function" "login_user" {
  filename         = data.archive_file.lambda_login_user.output_path  
  function_name    = "lambda-login-user"    
  role            = aws_iam_role.lambda_exec_role.arn  
  handler         = "index.handler"        
  runtime         = "nodejs16.x"         
  
  # Hash del código fuente para detectar cambios
  source_code_hash = data.archive_file.lambda_login_user.output_base64sha256

  reserved_concurrent_executions = var.lambda_reserved_concurrency
  
  # Configuración de red VPC para acceder a RDS
  vpc_config {
    subnet_ids         = [aws_subnet.public_a.id, aws_subnet.public_b.id]
    security_group_ids = [aws_security_group.lambda_sg.id]  
  }

  # Variables de entorno para la conexión a la base de datos
  environment {
    variables = {
      DB_HOST = aws_db_instance.postgres_db.endpoint  # Endpoint de RDS
      DB_NAME = aws_db_instance.postgres_db.db_name   # Nombre de la base de datos
      DB_USER = var.db_username                       # Usuario de la base de datos
      DB_PASS = var.db_password                       # Contraseña de la base de datos
    }
  }
    tracing_config {
    mode = "Active"
  }
}