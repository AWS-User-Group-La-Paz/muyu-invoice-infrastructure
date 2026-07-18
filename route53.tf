resource "aws_route53_zone" "domain" {
  name = var.domain
}

resource "aws_route53_record" "domain" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = module.cluster.alb_dns_name
    zone_id                = module.cluster.alb_zone_id
    evaluate_target_health = true
  }
}
