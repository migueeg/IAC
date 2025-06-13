resource "aws_kms_key" "frontend_kms" {
  description             = "Clave KMS para objetos del frontend"
  enable_key_rotation     = true
  deletion_window_in_days = 10
}
