resource "aws_s3_bucket" "this" {
  bucket = "${var.prefix_name}-${var.lb_name}"
  acl    = "private"
  region = data.aws_region.current.name

  versioning {
    enabled = true
  }
}
