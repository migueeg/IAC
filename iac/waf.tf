provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

resource "aws_wafv2_web_acl" "cloudfront_waf" {
  provider    = aws.virginia
  name        = "cloudfront-web-acl"
  description = "WAF para proteger la distribucion de CloudFront"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "cloudfrontWAF"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "block-bad-user-agents"
    priority = 1

    action {
      block {}
    }

    statement {
      byte_match_statement {
        search_string = "BadBot"

        field_to_match {
          single_header {
            name = "user-agent"
          }
        }

        positional_constraint = "CONTAINS"

        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "blockBadUserAgents"
      sampled_requests_enabled   = true
    }
  }
}