resource "aws_lb" "this" {
  name               = "${var.prefix_name}-${var.lb_name}"
  internal           = data.aws_lb.this.internal
  load_balancer_type = "network"

  enable_deletion_protection = true
  enable_cross_zone_load_balancing = length(data.aws_lb.this.subnets) > 1 ? true : false

  # For each subnet on existing ALB, We will create one eip (to reserve a private ip)
  # and dynamicly create a subnet_mapping containg each eip and one subnet where alb is available
  dynamic "subnet_mapping"{
    for_each = zipmap(data.aws_lb.this.subnets, aws_eip.this.*.id)
    content {
      subnet_id     = subnet_mapping.key
      allocation_id = subnet_mapping.value
    }
  }

  tags = data.aws_lb.this.tags
}

resource "aws_lb_target_group" "http" {
  count = var.reply_http == true ? 1 : 0
  name  = "${var.prefix_name}-${var.lb_name}-http"

  proxy_protocol_v2 = false
  target_type       = "ip"
  port              = "80"
  protocol          = "TCP"

  vpc_id = data.aws_lb.this.vpc_id

}

resource "aws_lb_target_group" "https" {
  count = var.reply_https == true ? 1 : 0
  name  = "${var.prefix_name}-${var.lb_name}-https"

  proxy_protocol_v2 = false
  target_type       = "ip"
  port              = "443"
  protocol          = "TCP"

  vpc_id = data.aws_lb.this.vpc_id

}

resource "aws_lb_listener" "http" {
  count = var.reply_http == true ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http[count.index].arn
  }
}

resource "aws_lb_listener" "https" {
  count = var.reply_https == true ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https[count.index].arn
  }
}
