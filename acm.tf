resource "aws_acm_certificate" "domain" {
  domain_name       = var.domain
  validation_method = "DNS"
}

locals {
  certificate_validation = one(aws_acm_certificate.domain.domain_validation_options)
}

resource "aws_route53_record" "certificate_validation" {
  zone_id = aws_route53_zone.domain.zone_id
  name    = local.certificate_validation.resource_record_name
  type    = local.certificate_validation.resource_record_type
  ttl     = 60
  records = [local.certificate_validation.resource_record_value]
}

resource "aws_acm_certificate_validation" "domain" {
  certificate_arn         = aws_acm_certificate.domain.arn
  validation_record_fqdns = [aws_route53_record.certificate_validation.fqdn]
}
