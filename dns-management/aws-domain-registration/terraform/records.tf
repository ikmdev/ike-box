# use existing public hosted zone created during domain registration

data "aws_route53_zone" "public" {
  name       = var.domain_name
}


resource "aws_route53_record" "subdomains" {
  for_each = toset(var.subdomains)
  zone_id  = data.aws_route53_zone.public.zone_id
  name     = "${each.key}.${var.domain_name}"
  type     = "A"
  ttl      = 300
  records  = [var.target_ip]
}

resource "aws_route53_record" "subdomains" {
  zone_id  = data.aws_route53_zone.public.zone_id
  name     = "_acme-challenge"
  type     = "TXT"
  ttl      = 300
  records  = [var.dns_challenge_value]
}
