resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.my_vpc.id

  tags = merge(
    var.tags
  )
  depends_on = [ aws_vpc.my_vpc ]
}
