resource "aws_eip" "this" {
  count = length(data.aws_lb.this.subnets)

  tags = data.aws_lb.this.tags
}
