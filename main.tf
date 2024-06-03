# Project
# Create:
#    - SG for Web Server
#    - Launch Configuration with Auto AMI Lookup
#    - ASG using 2 AZ
#    - ALB in 2 AZ
#
# 

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
  default_tags {
      tags = merge(var.tags, {Environment = "Dev"})
    }
}

data "aws_availability_zones" "working" {}


#------------------------
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16" #var.vpc_cider_block
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "routetable" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_subnet" "my_subnet1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24" #var.vpc_cider_block_sub1
  availability_zone = "eu-north-1a"

  tags = {
    Name = "my_subnet1"
  }
}

resource "aws_subnet" "my_subnet2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24" #var.vpc_cider_block_sub2
  availability_zone = "eu-north-1b"

  tags = {
    Name = "my_subnet2"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet1.id
  route_table_id = aws_route_table.routetable.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.my_subnet2.id
  route_table_id = aws_route_table.routetable.id
}
#------------------------------------------

resource "aws_security_group" "web" {
  name   = "Dynamic Security Group"
  vpc_id = aws_vpc.my_vpc.id # VPC id

  dynamic "ingress" {
    for_each = ["8080", "443"]
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

resource "aws_lb" "web" {
  name               = "WebServer-HighlyAvailable-ALB"
  internal = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id]
  subnets            = [aws_subnet.my_subnet1.id, aws_subnet.my_subnet2.id]
}

resource "aws_lb_target_group" "web" {
  name                 = "WebServer-HighlyAvailable-TG"
  vpc_id               = aws_vpc.my_vpc.id
  port                 = 8080
  protocol             = "HTTP"
  deregistration_delay = 10 # seconds
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

data "template_file" "init" {
  template = filebase64("${path.module}/data.sh")
}

resource "aws_launch_template" "web" {
    name_prefix     = "WebServer-Highly-Available-LC-"
    image_id = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    user_data = base64encode(data.template_file.init.rendered)

    network_interfaces {
      associate_public_ip_address = true
      security_groups = [aws_security_group.web.id]
    }
  
}

resource "aws_autoscaling_group" "web" {
  desired_capacity     = 2
  max_size             = 2
  min_size             = 1
  health_check_grace_period = 1000
  health_check_type = "ELB"
  vpc_zone_identifier  = [aws_subnet.my_subnet1.id, aws_subnet.my_subnet2.id]
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web.arn]

  tag {
    key                 = "Name"
    value               = "my_web-server"
    propagate_at_launch = true
  }

  depends_on = [
    aws_lb.web,
    aws_lb_target_group.web,
    aws_lb_listener.http
  ]
}

#-----------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.my_subnet1.id
  user_data = filebase64("${path.module}/data.sh")

  tags = {
    Name = "my_web-server-1 " #${count.index + 1}
  }
}

output "web_loadbalanser_url" {
  value = aws_lb.web.dns_name
}
