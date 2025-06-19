# use existing public hosted zone created during domain registration

data "aws_route53_zone" "public" {
  name       = main.domain_name
  depends_on = [aws_route53domains_domain.main]
}


resource "aws_route53_record" "subdomains" {
  for_each = toset(var.subdomains)
  zone_id  = aws_route53_zone.public.zone_id
  name     = "${each.key}.${var.domain_name}"
  type     = "A"
  ttl      = 300
  records  = [var.target_ip]
}
