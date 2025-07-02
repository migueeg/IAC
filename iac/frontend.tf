resource "aws_s3_bucket_object" "frontend_files" {
  # checkov:skip=CKV_AWS_186 Cifrado con CMK no necesario para archivos estáticos en entorno local
  for_each = fileset("${path.module}/../frontend", "*/")

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
}
