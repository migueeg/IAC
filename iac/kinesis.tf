resource "aws_kinesis_stream" "event_stream" {
  name             = "event-stream"
  shard_count      = 1
  retention_period = 24
  shard_level_metrics = ["IncomingBytes", "OutgoingBytes"]

  tags = {
    Environment = "dev"
    Name        = "event-stream"
  }
}