resource "aws_lambda_function" "http_updater" {
  count = var.reply_http == true ? 1 : 0

  filename      = "lambda.zip"
  function_name = "http-${var.prefix_name}-${var.lb_name}"
  role          = aws_iam_role.this.arn
  handler       = "populate_NLB_TG_with_ALB.lambda_handler"

  source_code_hash = filebase64sha256("lambda.zip")

  runtime     = "python2.7"
  memory_size = 128
  timeout     = 300

  environment {
    variables = {
      ALB_DNS_NAME                      = data.aws_lb.this.dns_name
      ALB_LISTENER                      = "80"
      S3_BUCKET                         = aws_s3_bucket.this.id
      NLB_TG_ARN                        = aws_lb_target_group.http[count.index].arn
      MAX_LOOKUP_PER_INVOCATION         = 50
      INVOCATIONS_BEFORE_DEREGISTRATION = 10
      CW_METRIC_FLAG_IP_COUNT           = true
    }
  }
}

resource "aws_lambda_function" "https_updater" {
  count = var.reply_https == true ? 1 : 0

  filename      = "lambda.zip"
  function_name = "https-${var.prefix_name}-${var.lb_name}"
  role          = aws_iam_role.this.arn
  handler       = "populate_NLB_TG_with_ALB.lambda_handler"

  source_code_hash = filebase64sha256("lambda.zip")

  runtime     = "python2.7"
  memory_size = 128
  timeout     = 300

  environment {
    variables = {
      ALB_DNS_NAME                      = data.aws_lb.this.dns_name
      ALB_LISTENER                      = "443"
      S3_BUCKET                         = aws_s3_bucket.this.id
      NLB_TG_ARN                        = aws_lb_target_group.https[count.index].arn
      MAX_LOOKUP_PER_INVOCATION         = 50
      INVOCATIONS_BEFORE_DEREGISTRATION = 10
      CW_METRIC_FLAG_IP_COUNT           = true
    }
  }
}

resource "aws_lambda_permission" "http" {
  count = var.reply_http == true ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.http_updater[count.index].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}

resource "aws_lambda_permission" "https" {
  count = var.reply_https == true ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.https_updater[count.index].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}
