resource "aws_s3_bucket_object" "frontend_files" {
  for_each = fileset("${path.module}/../frontend", "**") # cambia también "*/" por "**" para incluir subdirectorios

  bucket = aws_s3_bucket.mi_bucket_web.bucket
  key    = each.value
  source = "${path.module}/../frontend/${each.value}"
  etag   = filemd5("${path.module}/../frontend/${each.value}")

  content_type = lookup({
    html = "text/html"
    js   = "application/javascript"
    css  = "text/css"
    png  = "image/png"
    jpg  = "image/jpeg"
    jpeg = "image/jpeg"
    webp = "image/webp"
    ico  = "image/x-icon"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")

  server_side_encryption = "aws:kms"
  kms_key_id             = aws_kms_key.frontend_kms.arn
}