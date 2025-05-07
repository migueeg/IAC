# Configuración del paquete ZIP para la función Lambda
# Este bloque empaqueta el código fuente y sus dependencias
data "archive_file" "lambda_login_user" {
  type        = "zip"                           # Formato de compresión
  source_dir  = "${path.module}/../loginUser"   # Directorio donde está el código fuente
  output_path = "${path.module}/bin/loginUser.zip" # Donde se guardará el ZIP
}

# Definición de la función Lambda
# Este recurso crea la función Lambda en AWS
resource "aws_lambda_function" "login_user" {
  filename         = data.archive_file.lambda_login_user.output_path  # Archivo ZIP con el código
  function_name    = "lambda-login-user"    # Nombre de la función en AWS
  role            = aws_iam_role.lambda_exec_role.arn  # Rol IAM que define permisos
  handler         = "index.handler"         # Punto de entrada de la función (archivo.función)
  runtime         = "nodejs16.x"           # Versión de Node.js a usar
  
  # Hash del código fuente para detectar cambios
  source_code_hash = data.archive_file.lambda_login_user.output_base64sha256
  
  # Configuración de red VPC para acceder a RDS
  vpc_config {
    subnet_ids         = [aws_subnet.public_a.id, aws_subnet.public_b.id]  # Subredes donde se ejecuta
    security_group_ids = [aws_security_group.lambda_sg.id]  # Reglas de firewall
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