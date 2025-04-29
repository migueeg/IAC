resource "aws_s3_bucket" "mi_bucket_web" {
  bucket = "primerbuckets3-probandoandojeje"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}