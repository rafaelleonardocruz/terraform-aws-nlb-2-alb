variable "lb_name" {
  description = "The name of ALB that you want to redirect your traffic"
}

variable "prefix_name" {
  description = "Prefix to refer your NLB resources"
  default = "nlb-fowarder"
}

variable "reply_http" {
  description = "Define if NLB will foward HTTP trafil: true or false"
  type = bool
}

variable "reply_https" {
  description = "Define if NLB will foward HTTPS trafil: true or false"
  type = bool
}
