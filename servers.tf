
resource "aws_instance" "lessagasmp3" {
  ami = "ami-0de12f76efe134f2f"
  instance_type = "t2.micro"
  key_name = "lessagasmp3"
  security_groups = [aws_security_group.allow_ssh.id]
  subnet_id = aws_subnet.lessagasmp3_a.id
  
  tags = {
    Name = "lessagasmp3"
  }
}
