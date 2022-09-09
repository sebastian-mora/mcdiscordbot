data "aws_route53_zone" "primary" {
  name = var.domain_name
}


resource "aws_route53_record" "vanilla_mc_rusecrew_com" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = format("%s.%s", var.name, var.domain_name)
  type    = "A"
  ttl     = 300
  records = [aws_instance.instance.public_ip]
}

