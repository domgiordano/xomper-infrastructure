# Hosted Zone Data Source
data "aws_route53_zone" "web_zone" {
  private_zone = false
  zone_id      = "Z0212401124Q11NWHM1D1"
}

# API Gateway custom domain DNS record
resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.web_zone.zone_id
  name    = local.api_domain_name
  type    = "A"

  alias {
    name                   = module.api.domain_regional_domain_name
    zone_id                = module.api.domain_regional_zone_id
    evaluate_target_health = true
  }
}
