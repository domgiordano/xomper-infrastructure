resource "aws_acm_certificate" "web_app" {

  domain_name       = local.domain_name
  validation_method = "DNS"
  tags = merge(local.standard_tags, tomap({ "name" = "${var.app_name}-disciplines-certification" }))
  lifecycle {
    create_before_destroy = true
  }

}

# Step 2: Validate certificate
resource "aws_route53_record" "domains" {
  for_each = {
      for dvo in aws_acm_certificate.web_app.domain_validation_options : dvo.domain_name => {
          name = dvo.resource_record_name
          record = dvo.resource_record_value
          type = dvo.resource_record_type
      }
  }
  allow_overwrite = true
  name = each.value.name
  records = [each.value.record]
  ttl = 60
  type = each.value.type
  zone_id = data.aws_route53_zone.web_zone.zone_id
}

resource "aws_acm_certificate_validation" "web_app_validate" {
  certificate_arn         = aws_acm_certificate.web_app.arn
  validation_record_fqdns = [for record in aws_route53_record.domains : record.fqdn]
}
