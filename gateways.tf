
resource "aws_internet_gateway" "lessagasmp3" {
  vpc_id = aws_vpc.lessagasmp3.id
  tags = {
    Name = "lessagasmp3"
  }
}
