#
# Registers a custom domain name for use with AWS API Gateway.
# 
# Used by the user API
#

resource "aws_api_gateway_domain_name" "client_dev" {
  certificate_arn = var.CLIENT_CERTIFICATE_ARN
  domain_name     = var.CLIENT_DOMAIN_NAME
}


# DNS record using Route53.

resource "aws_route53_record" "client_dev" {
  name    = aws_api_gateway_domain_name.client_dev.domain_name
  type    = "A"
  zone_id = var.DOMAIN_HOSTED_ZONE_ID

  alias {
    evaluate_target_health = false
    name                   = aws_api_gateway_domain_name.client_dev.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.client_dev.cloudfront_zone_id
  }
}

resource "aws_api_gateway_base_path_mapping" "client_dev_user_api" {
  api_id      = aws_api_gateway_rest_api.user_api.id
  stage_name  = aws_api_gateway_stage.user_api_prod.stage_name
  domain_name = aws_api_gateway_domain_name.client_dev.domain_name
  base_path = aws_api_gateway_stage.user_api_prod.stage_name
}