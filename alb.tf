resource "aws_alb" "application_load_balancer" {
  name               = "My-alb"
  internal           = var.internal
  load_balancer_type = var.load_balancer_type

  subnets         = aws_subnet.private_subnets[*].id
  security_groups = [aws_security_group.web.id]

  tags = merge(
    {
      Name        = "Dummy",
      Owner       = "Alex",
    },
    var.tags
  )
  depends_on = [
    aws_security_group.web
  ]
}

resource "aws_alb_target_group" "alb_tg" {
  name_prefix = "alb-tg"
  port        = 8080
  protocol    = "TCP"
  vpc_id      = aws_vpc.my_vpc.id
  target_type = "lambda" #"instans" или "ip", или "lambda"

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = var.health_check_interval
    timeout             = 5
#    healthy_threshold   = var.health_check_healthy_threshold
#   unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  load_balancing_algorithm_type = var.load_balancing_algorithm

  tags = merge(
    {
      Name        = "Dummy",
      Owner       = "Alex",
    },
    var.tags
  )
}

resource "aws_alb_listener" "application_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = var.listener_port
  protocol          = var.listener_protocol
  default_action {
    target_group_arn = aws_alb_target_group.alb_tg.arn
    type             = var.listener_type
  }
}

# Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Route Table Association
resource "aws_route_table_association" "public_route_table_assoc" {
  count = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}
