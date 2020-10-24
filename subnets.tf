
resource "aws_subnet" "lessagasmp3_a" {
  vpc_id     = aws_vpc.lessagasmp3.id
  cidr_block = cidrsubnet(aws_vpc.lessagasmp3.cidr_block, 3, 1)
  availability_zone = "eu-west-3a"

  tags = {
    Name = "lessagasmp3"
  }
}

resource "aws_route_table" "lessagasmp3" {
  vpc_id = aws_vpc.lessagasmp3.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lessagasmp3.id
  }

  tags = {
    Name = "lessagasmp3"
  }
}

resource "aws_route_table_association" "lessagasmp3" {
  subnet_id = aws_subnet.lessagasmp3_a.id
  route_table_id = aws_route_table.lessagasmp3.id
}
