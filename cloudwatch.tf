resource "aws_cloudwatch_event_rule" "this" {
  name                = "cron-minute"
  schedule_expression = "rate(1 minute)"
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "http" {
  count = var.reply_http == true ? 1 : 0

  rule      = aws_cloudwatch_event_rule.this.name
  target_id = "TriggerStaticPort80"
  arn       = aws_lambda_function.http_updater[count.index].arn
}

resource "aws_cloudwatch_event_target" "https" {
  count = var.reply_https == true ? 1 : 0

  rule      = aws_cloudwatch_event_rule.this.name
  target_id = "TriggerStaticPort443"
  arn       = aws_lambda_function.https_updater[count.index].arn
}

