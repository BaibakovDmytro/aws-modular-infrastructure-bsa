# Define a schedule: trigger every 5 minutes
resource "aws_cloudwatch_event_rule" "every_five_minutes" {
  name                = "qlr-every-five-minutes"
  description         = "Trigger test lambda periodically"
  schedule_expression = "rate(5 minutes)"
}

# Set the target for the schedule
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_five_minutes.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.test_automation_lambda.arn
}

# Grant permission for EventBridge to invoke the Lambda
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_automation_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_five_minutes.arn
}

# Monitor Lambda for any execution errors
resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "qlr-lambda-failure-alert"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "This alarm triggers if the scoring Lambda fails"
  
  # Connect this alarm to our SNS topic from the SERVICES layer
  alarm_actions       = [data.terraform_remote_state.services.outputs.sns_topic_arn]

  dimensions = {
    FunctionName = aws_lambda_function.test_automation_lambda.function_name
  }
}