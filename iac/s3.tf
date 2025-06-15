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

# Versioning habilitado (requerido para replicación)
resource "aws_s3_bucket_versioning" "mi_bucket_versioning" {
  bucket = aws_s3_bucket.mi_bucket_web.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Replicación entre regiones
resource "aws_s3_bucket_replication_configuration" "replication" {
  bucket = aws_s3_bucket.mi_bucket_web.id
  role   = aws_iam_role.s3_replication_role.arn

  rules {
    id     = "cross-region-replication"
    status = "Enabled"

    destination {
      bucket        = "arn:aws:s3:::bucket-destino-replica"
      storage_class = "STANDARD"
    }

    filter {
      prefix = ""
    }
  }

  depends_on = [aws_s3_bucket_versioning.mi_bucket_versioning]
}

# Encriptación por defecto con KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.mi_bucket_web.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.lambda_env_kms.arn
    }
  }
}

# Logging habilitado
resource "aws_s3_bucket_logging" "mi_bucket_logging" {
  bucket        = aws_s3_bucket.mi_bucket_web.id
  target_bucket = "nombre-del-bucket-de-logs"
  target_prefix = "logs/"

  depends_on = [aws_s3_bucket.mi_bucket_web]
}

# Ciclo de vida de logs
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

# Política OAI para CloudFront
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

# Bloqueo de acceso público
resource "aws_s3_bucket_public_access_block" "no_block" {
  bucket = aws_s3_bucket.mi_bucket_web.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Notificaciones de eventos
resource "aws_s3_bucket_notification" "mi_bucket_eventos" {
  bucket = aws_s3_bucket.mi_bucket_web.id

  event {
    event              = "s3:ObjectCreated:*"
    lambda_function_arn = aws_lambda_function.mi_lambda_function.arn
  }

  event {
    event              = "s3:ObjectRemoved:*"
    lambda_function_arn = aws_lambda_function.mi_lambda_function.arn
  }

  depends_on = [
    aws_s3_bucket.mi_bucket_web,
    aws_lambda_permission.s3_lambda_permission
  ]
}