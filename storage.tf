
resource "aws_s3_bucket" "lessagasmp3" {
  bucket = "lessagasmp3"
  acl    = "private"
  tags = var.tags
}
