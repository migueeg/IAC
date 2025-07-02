resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI para acceso seguro desde CloudFront a bucket S3"
}

resource "aws_cloudfront_distribution" "cdn" {
  # checkov:skip=CKV_AWS_174 Certificado por defecto permitido en entorno de pruebas
  # checkov:skip=CKV_AWS_310 Failover innecesario para entorno estático y de pruebas
  # checkov:skip=CKV_AWS_374 No se requiere restricción geográfica en entorno de pruebas
  # checkov:skip=CKV_AWS_86 Logging innecesario para entorno de desarrollo
  # checkov:skip=CKV_AWS_68 WAF no requerido en entorno local o sin tráfico real
  origin {
    domain_name = aws_s3_bucket.mi_bucket_web.bucket_regional_domain_name
    origin_id   = "S3Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN for static website"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3Origin"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "CloudFrontForS3Website"
  }

  depends_on = [aws_s3_bucket_policy.bucket_oai_policy]
}