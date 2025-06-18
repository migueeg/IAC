resource "aws_s3_bucket" "mi_bucket_web" {
  bucket = "primerbuckets3-probandoandojeje"

  tags = {
    Name = "S3 Website Bucket"
  }
}

resource "aws_s3_bucket_website_configuration" "web_config" {
  bucket = aws_s3_bucket.mi_bucket_web.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }

  routing_rule {
    condition {
      http_error_code_returned_equals = "404"
    }
    redirect {
      replace_key_with = "index.html"
    }
  }
}

resource "aws_s3_bucket_versioning" "mi_bucket_versioning" {
  bucket = aws_s3_bucket.mi_bucket_web.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_iam_role" "s3_replication_role" {
  name = "s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "s3.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_replication_policy_attach" {
  role       = aws_iam_role.s3_replication_role.name
  policy_arn = aws_iam_policy.s3_replication_policy.arn
}

# resource "aws_s3_bucket_replication_configuration" "replication" {
#   bucket = aws_s3_bucket.mi_bucket_web.id
#   role   = aws_iam_role.s3_replication_role.arn

#   rule {
#     id     = "cross-region-replication"
#     status = "Enabled"
#     destination {
#       bucket        = aws_s3_bucket.logs_bucket.arn
#       storage_class = "STANDARD"

#       delete_marker_replication {
#         status = "Disabled"
#       }
#     }
#     filter {
#       prefix = ""
#     }
#   }

#   depends_on = [
#     aws_s3_bucket_versioning.mi_bucket_versioning,
#     aws_s3_bucket_versioning.logs_bucket_versioning
#   ]
# }

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.mi_bucket_web.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.lambda_env_kms.arn
    }
  }
}

resource "aws_s3_bucket" "logs_bucket" {
  bucket = "primerbuckets3-logs"
  tags = {
    Name = "S3 Logs Bucket"
  }
}

resource "aws_s3_bucket_logging" "mi_bucket_logging" {
  bucket        = aws_s3_bucket.mi_bucket_web.id
  target_bucket = aws_s3_bucket.logs_bucket.id
  target_prefix = "logs/"
  depends_on    = [aws_s3_bucket.mi_bucket_web, aws_s3_bucket.logs_bucket]
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

resource "aws_s3_bucket_notification" "mi_bucket_eventos" {
  bucket = aws_s3_bucket.mi_bucket_web.id

  lambda_function {
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
    lambda_function_arn = aws_lambda_function.sqs_ses_consumer.arn
  }

  depends_on = [
    aws_s3_bucket.mi_bucket_web,
    aws_lambda_permission.s3_lambda_permission
  ]
}

resource "aws_lambda_permission" "s3_lambda_permission" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sqs_ses_consumer.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.mi_bucket_web.arn
} 

resource "aws_iam_policy" "s3_replication_policy" {
  name = "s3-replication-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.mi_bucket_web.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ],
        Resource = [
          "${aws_s3_bucket.mi_bucket_web.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ],
        Resource = [
          "${aws_s3_bucket.logs_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_versioning" "logs_bucket_versioning" {
  bucket = aws_s3_bucket.logs_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}