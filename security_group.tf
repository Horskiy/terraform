resource "aws_security_group" "web" {
  name   = "Dynamic Security Group"
  vpc_id = aws_vpc.my_vpc.id # VPC id

  dynamic "ingress" {
    for_each = ["8080", "443", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Dynamic Security Group"
    Owner = "Dummy"
  }
}
