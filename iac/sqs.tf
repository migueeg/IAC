resource "aws_sqs_queue" "event_queue" {
  name                      = "event-queue"
  visibility_timeout_seconds = 30
}
resource "aws_sqs_queue" "lambda_dlq" {
  name = "lambda-loginUser-dlq"
}
