
resource "aws_vpc" "lessagasmp3" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = var.tags
}

resource "aws_eip" "lessagasmp3" {
  instance = aws_instance.lessagasmp3.id
  vpc      = true
  tags     = var.tags
}
