data "aws_lb" "this" {
  name = var.lb_name
}

data "aws_region" "current" {}
