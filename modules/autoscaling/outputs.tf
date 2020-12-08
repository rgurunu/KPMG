output "lb_dns_name" {
  value = "${aws_lb.web-alb.dns_name}"
}
