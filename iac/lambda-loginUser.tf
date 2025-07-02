# Configuración del paquete ZIP para la función Lambda
# Este bloque empaqueta el código fuente y sus dependencias
data "archive_file" "lambda_login_user" {
  type        = "zip"                           
  source_dir  = "${path.module}/../loginUser"  
  output_path = "${path.module}/bin/loginUser.zip" 
}

resource "aws_lambda_function" "login_user" {
  # checkov:skip=CKV_AWS_272 Code signing unnecessary for local testing environment
  # checkov:skip=CKV_AWS_116 Dead Letter Queue unnecessary for local testing environment
  # checkov:skip=CKV_AWS_50 X-Ray tracing unnecessary for local testing environment
  # checkov:skip=CKV_AWS_173 Environment variable encryption unnecessary for local testing
  # checkov:skip=CKV_AWS_115 Concurrent execution limits unnecessary for local testing environment
  filename         = data.archive_file.lambda_login_user.output_path  
  function_name    = "lambda-login-user"    
  role            = aws_iam_role.lambda_exec_role.arn  
  handler         = "index.handler"        
  runtime         = "nodejs18.x"         
  
  # Hash del código fuente para detectar cambios
  source_code_hash = data.archive_file.lambda_login_user.output_base64sha256
  
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
}