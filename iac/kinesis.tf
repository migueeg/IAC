resource "aws_kinesis_stream" "event_stream" {
  # checkov:skip=CKV_AWS_43 Justificación: Cifrado no necesario en entorno dev/test
  # checkov:skip=CKV_AWS_185 Justificación: No se requiere CMK en entorno dev/test
  name             = "event-stream"
  shard_count      = 1
  retention_period = 24
  shard_level_metrics = ["IncomingBytes", "OutgoingBytes"]

  tags = {
    Environment = "dev"
    Name        = "event-stream"
  }
}