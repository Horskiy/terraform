output "load_balancer_dns_name" {
  description = "LoadBalancer dns name"
  value = aws_alb.application_load_balancer.dns_name
}
