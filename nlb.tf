resource "aws_lb" "this" {
  name               = "${var.prefix_name}-${var.lb_name}"
  internal           = data.aws_lb.this.internal
  load_balancer_type = "network"
  subnets            = data.aws_lb.this.subnets

  enable_deletion_protection = true
  enable_cross_zone_load_balancing = length(data.aws_lb.this.subnets) > 1 ? true : false

  tags = data.aws_lb.this.tags
}
