variable "lb_name" {
  description = "The name of ALB that you want to redirect your traffic"
}

variable "prefix_name" {
  description = "Prefix to refer your NLB resources"
  default = "nlb-fowarder"
}
