#
# Provides a Route53 record resource.
# 
# Creates the "admin" api DNS record
#

# Get existing custom domain created by Chalice
data "aws_api_gateway_domain_name" "admin_dev" {
  domain_name = var.API_DOMAIN_NAME
}

resource "aws_route53_record" "admin_dev" {
  name    = data.aws_api_gateway_domain_name.admin_dev.domain_name
  type    = "A"
  zone_id = var.DOMAIN_HOSTED_ZONE_ID

  alias {
    evaluate_target_health = false
    name                   = data.aws_api_gateway_domain_name.admin_dev.cloudfront_domain_name
    zone_id                = data.aws_api_gateway_domain_name.admin_dev.cloudfront_zone_id
  }
}