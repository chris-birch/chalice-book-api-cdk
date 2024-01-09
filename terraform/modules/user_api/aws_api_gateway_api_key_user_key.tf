resource "aws_api_gateway_api_key" "user_key" {
  name = "user_api_key"

  # lifecycle {
  #   prevent_destroy = true
  # }
}