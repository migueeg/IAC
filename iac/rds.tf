# Instancia de PostgreSQL
resource "aws_db_instance" "postgres_db" {
  identifier           = "eventos-db"
  engine              = "postgres"
  engine_version      = "14"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  publicly_accessible    = true

  db_name             = "eventosdb"
  username            = var.db_username
  password            = var.db_password
  
  # Configuración de VPC
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  
  skip_final_snapshot = true
  
  # Configuración de logs
  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = {
    Environment = var.environment
  }
}

# Grupo de subredes para RDS
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "RDS subnet group"
  }
}

# Security Group para RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.main_vpc.id

  # Regla para acceso a PostgreSQL
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "PostgreSQL access from anywhere (development only)"
  }

  # Acceso desde Lambda
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
    description     = "Access from Lambda functions"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group para las funciones Lambda
resource "aws_security_group" "lambda_sg" {
  name        = "lambda-security-group"
  description = "Security group for Lambda functions"
  vpc_id      = aws_vpc.main_vpc.id

  # Permitir todo el tráfico saliente
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "lambda-security-group"
    Environment = var.environment
  }
}