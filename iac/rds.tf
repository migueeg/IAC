# Clave KMS para Performance Insights
resource "aws_kms_key" "rds_pi_kms" {
  description             = "KMS key for RDS Performance Insights"
  enable_key_rotation     = true
  deletion_window_in_days = 10

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid: "AllowRootAccess",
        Effect: "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action: "kms:*",
        Resource: "*"
      }
    ]
  })
}

resource "aws_kms_alias" "rds_pi_kms_alias" {
  name          = "alias/rds-performance-insights"
  target_key_id = aws_kms_key.rds_pi_kms.key_id
}

# Instancia de PostgreSQL
resource "aws_db_instance" "postgres_db" {
  identifier                   = "eventos-db"
  engine                       = "postgres"
  engine_version               = "14"
  auto_minor_version_upgrade   = true
  instance_class               = "db.t3.micro"
  allocated_storage            = 20
  multi_az                     = true
  publicly_accessible          = false

  db_name                      = "eventosdb"
  username                     = var.db_username
  password                     = var.db_password

  db_subnet_group_name         = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids       = [aws_security_group.rds_sg.id]

  storage_encrypted            = true
  kms_key_id                   = aws_kms_key.rds_kms.arn

  skip_final_snapshot          = true
  deletion_protection          = true

  enabled_cloudwatch_logs_exports = ["postgresql", "error", "slowquery"]
  copy_tags_to_snapshot            = true
  iam_database_authentication_enabled = true

  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rds_monitoring.arn

  performance_insights_enabled            = true
  performance_insights_retention_period   = 7
  performance_insights_kms_key_id         = aws_kms_key.rds_pi_kms.arn

  tags = {
    Environment = var.environment
  }
}

# Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]

  tags = {
    Name = "RDS subnet group"
  }
}

# Security Group RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "PostgreSQL access from anywhere (development only)"
  }

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
    description = "Allow all outbound traffic"
  }
}

# Security Group Lambda
resource "aws_security_group" "lambda_sg" {
  name        = "lambda-security-group"
  description = "Security group for Lambda functions"
  vpc_id      = aws_vpc.main_vpc.id

  egress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.rds_sg.id]
    description     = "Allow outbound PostgreSQL traffic to RDS"
  }

  tags = {
    Name        = "lambda-security-group"
    Environment = var.environment
  }
}

# KMS general para cifrado en reposo
data "aws_caller_identity" "current" {}

resource "aws_kms_key" "rds_kms" {
  description             = "KMS key for RDS encryption at rest"
  enable_key_rotation     = true
  deletion_window_in_days = 10

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "rds-kms-policy",
    Statement = [
      {
        Sid    = "AllowRootAccount",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      }
    ]
  })
}
