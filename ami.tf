data "template_file" "init" {
  template = file("${path.module}/data.sh")
}

resource "aws_launch_template" "web_server" {
  name_prefix   = "web-server"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.web.id]
#    subnet_id                   = aws_subnet.private_subnets[*].id #element(aws_subnet.private_subnets.*.id, count.index)
  }

  user_data = base64encode(data.template_file.init.rendered)
  
  tags = {
    Name = "web-server"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
