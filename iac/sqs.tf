resource "aws_sqs_queue" "event_queue" {
  name                      = "event-queue"
  visibility_timeout_seconds = 30
}