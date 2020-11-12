
resource "aws_route53_zone" "lessagasmp3" {
  name = "les-sagas-mp3.fr"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.lessagasmp3.zone_id
  name    = "les-sagas-mp3.fr"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.lessagasmp3.public_ip]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.lessagasmp3.zone_id
  name    = "www.les-sagas-mp3.fr"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.lessagasmp3.public_ip]
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.lessagasmp3.zone_id
  name    = "api.les-sagas-mp3.fr"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.lessagasmp3.public_ip]
}

resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.lessagasmp3.zone_id
  name    = "app.les-sagas-mp3.fr"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.lessagasmp3.public_ip]
}
