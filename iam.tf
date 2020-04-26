data "aws_iam_policy_document" "this" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
    ]
    sid = "LambdaBasicExecutionPolicy"
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]
    sid = "AllowS3Access"
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
    ]
    resources = [
      "*"
    ]
    sid = "ChangeTargetGroups"
  }

  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DescribeTargetHealth"
    ]
    resources = [
      "*"
    ]
    sid = "ReadTargetGroups"
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:putMetricData"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "this" {
  name = "lambda-${var.prefix_name}-${var.lb_name}"
  role = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "assume_role" {                                   
  statement {
    effect = "Allow"
    actions = [ 
      "sts:AssumeRole",
    ]   
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name = "lambda-${var.prefix_name}-${var.lb_name}"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
