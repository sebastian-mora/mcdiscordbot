data "aws_route53_zone" "primary" {
  name = var.domain_name
}


resource "aws_route53_record" "vanilla_mc_rusecrew_com" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name  = format("vanilla.%s", var.domain_name)
  type = "A"
  ttl = 300
  records = [aws_instance.vanilla.public_ip]
}

resource "aws_route53_record" "modded_mc_rusecrew_com" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name  = format("modded.%s", var.domain_name)
  type = "A"
  ttl = 300
  records = [aws_instance.modded.public_ip]
}