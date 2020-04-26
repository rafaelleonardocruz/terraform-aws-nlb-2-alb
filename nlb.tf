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
