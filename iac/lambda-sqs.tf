resource "aws_lambda_event_source_mapping" "sqs_to_create_event" {
  event_source_arn = aws_sqs_queue.event_queue.arn
  function_name    = aws_lambda_function.create_event.arn
  batch_size       = 1
  enabled          = true
}