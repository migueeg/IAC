resource "aws_kms_key" "kinesis_cmk" {
  description             = "Kinesis CMK for event stream encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 7

}

resource "aws_kinesis_stream" "event_stream" {
  name             = "event-stream"
  shard_count      = 1
  retention_period = 24
  shard_level_metrics = ["IncomingBytes", "OutgoingBytes"]

  encryption_type      = "KMS"
  kms_key_id           = aws_kms_key.kinesis_cmk.arn

  tags = {
    Environment = "dev"
    Name        = "event-stream"
  }
}