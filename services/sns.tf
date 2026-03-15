# Create a communication channel for system alerts

resource "aws_sns_topic" "system_alerts" {
  name = "qlr-system-alerts"
}

# Subscribe administrator email to receive notifications

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.system_alerts.arn
  protocol  = "email"
  endpoint  = "inform@qlrscore.com" # Replace with your real email
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.system_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchEvents"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.system_alerts.arn
      }
    ]
  })
}