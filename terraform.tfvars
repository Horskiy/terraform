access_key = "your key"
secret_key = "your key"

#vpc
region               = "eu-central-1"
vpc_cider_block = "10.0.0.0/16"
#vpc_security_group_ids = "aws_security_group.web.ids"
#instance_tenancy     = "default"
#enenable_dns_support   = false
#enable_dns_hostnames = false
health_check_path                = "/"
health_check_port                = 8080
health_check_protocol            = "HTTP"
health_check_interval            = 30
health_check_timeout             = 5
health_check_healthy_threshold   = 2
health_check_unhealthy_threshold = 2

public_subnet_cidr_blocks  = ["10.0.1.0/24", "10.0.11.0/24"]
private_subnet_cidr_blocks = ["10.0.2.0/24", "10.0.22.0/24"]
azs                        = ["eu-central-1a", "eu-central-1b"]

#alb
internal = false
load_balancer_type = "application"
alb_subnets       = ["aws_subnet.private_subnets.id"]
#security_group_ids = "aws_security_group.web.id"
load_balancing_algorithm = "round_robin"
listener_type     = "forward"
listener_port = 8080
listener_protocol = "HTTP"

#ami
instance_type   = "t2.micro"
key_name        = "my-key-pair"
desired_capacity = 2
max_size         = 3
min_size         = 1
