data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    action = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resource = [
      "arn:aws:logs:data.aws_region.name:${data.aws_caller_identity.current.account_id}:*"
    ]
    sid = "LambdaBasicExecutionPolicy"
  }

  statement {
    effect = "Allow"
    action = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resource = [
      "${aws_s3_bucket.this.arn}/*"
    ]
    sid = "AllowS3Access"
  }

  statement {
    effect = "Allow"
    action = [
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing>DeregisterTargets",
    ]
    resource = [
      # target group arns
    ]
    sid = "ChangeTargetGroups"
  }

  statement {
    effect = "Allow"
    action = [
      "elasticloadbalancing:DescribeTargetHealth"
    ]
    resource = "*"
    sid = "ReadTargetGroups"
  }

  statement {
    effect = "Allow"
    action = [
      "cloudwatch:putMetricData"
    ]
  }
}

resource "aws_iam_role_policy" "this" {
  name = "lambda-${var.prefix_name}-${var.lb_name}"
  role = aws_iam_role.static_lb_lambda.id
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "assume_role" {                                   
  statement {
    effect = "Allow"
    action = [ 
      "sts:AssumeRole",
    ]   
    principal {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name = "lambda-${var.prefix_name}-${var.lb_name}"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
