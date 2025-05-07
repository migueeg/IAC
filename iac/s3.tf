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
