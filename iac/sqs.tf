resource "aws_sqs_queue" "event_queue" {
  name                       = "event-queue"
  visibility_timeout_seconds = 30

  # Habilitar el cifrado utilizando una CMK personalizada
  kms_master_key_id = aws_kms_key.sqs_event_kms.arn
}

resource "aws_sqs_queue" "lambda_dlq_register_event" {
  name = "lambda-dlq-register-event"

  # Habilitar el cifrado utilizando una CMK personalizada
  kms_master_key_id = aws_kms_key.sqs_event_kms.arn
}
