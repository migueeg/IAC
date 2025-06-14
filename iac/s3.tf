resource "aws_s3_bucket" "mi_bucket_web" {
  bucket = "primerbuckets3-probandoandojeje"

  website {
    index_document = "index.html"
    error_document = "index.html"

    routing_rules = jsonencode([
      {
        Condition = {
          HttpErrorCodeReturnedEquals = "404"
        },
        Redirect = {
          ReplaceKeyWith = "index.html"
        }
      }
    ])
  }

  tags = {
    Name = "S3 Website Bucket"
  }
}

# Habilitar el registro de acceso para el bucket S3
resource "aws_s3_bucket_logging" "mi_bucket_logging" {
  bucket = aws_s3_bucket.mi_bucket_web.id  # Utiliza el ID de tu bucket S3

  # El destino donde se almacenarán los registros
  target_bucket = "nombre-del-bucket-de-logs"  # Este es un bucket diferente para almacenar los logs
  target_prefix = "logs/"  # Prefijo de los logs

  depends_on = [aws_s3_bucket.mi_bucket_web]
}

resource "aws_s3_bucket_lifecycle_configuration" "mi_bucket_lifecycle" {
  bucket = aws_s3_bucket.mi_bucket_web.id

  rule {
    id     = "log-expiration-rule"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    expiration {
      days = 30
    }
  }
}


resource "aws_s3_bucket_policy" "bucket_oai_policy" {
  bucket = aws_s3_bucket.mi_bucket_web.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudFrontOAI",
        Effect    = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai.iam_arn
        },
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.mi_bucket_web.arn}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "no_block" {
  bucket = aws_s3_bucket.mi_bucket_web.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Configuración de Notificaciones de Evento S3
resource "aws_s3_bucket_notification" "mi_bucket_eventos" {
  bucket = aws_s3_bucket.mi_bucket_web.id  # Reemplaza con el nombre correcto de tu bucket

  event {
    event     = "s3:ObjectCreated:*"  # Evento de creación de objeto
    lambda_function_arn = aws_lambda_function.mi_lambda_function.arn  # ARN de la función Lambda
  }

  event {
    event     = "s3:ObjectRemoved:*"  # Evento de eliminación de objeto
    lambda_function_arn = aws_lambda_function.mi_lambda_function.arn  # ARN de la función Lambda
  }

  depends_on = [
    aws_s3_bucket.mi_bucket_web,  # Asegura que el bucket ya esté creado
    aws_lambda_permission.s3_lambda_permission  # Asegura que el permiso esté asignado a Lambda
  ]
}
