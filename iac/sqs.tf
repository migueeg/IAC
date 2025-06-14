resource "aws_sqs_queue" "event_queue" {
  name                      = "event-queue"
  visibility_timeout_seconds = 30
  
  # Habilitar el cifrado utilizando la clave predeterminada de SQS
  kms_master_key_id = "alias/aws/sqs"
}

resource "aws_sqs_queue" "lambda_dlq" {
  name = "lambda-loginUser-dlq"
  
  # Habilitar el cifrado utilizando la clave predeterminada de SQS
  kms_master_key_id = "alias/aws/sqs"
}

resource "aws_sqs_queue" "lambda_dlq_register_event" {
  name = "lambda-dlq-register-event"
  
  # Habilitar el cifrado utilizando la clave predeterminada de SQS
  kms_master_key_id = "alias/aws/sqs"
}
