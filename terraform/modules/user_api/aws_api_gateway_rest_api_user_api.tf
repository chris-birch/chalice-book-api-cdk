#
# REST API used by end users to access app data
# 
# Secured by an API key
#

resource "aws_api_gateway_rest_api" "user_api" {
  name = "${var.project_name}_user_api_${random_id.generator.id}"
  description = "End-user API to query a single record from the DB"
}

resource "aws_api_gateway_resource" "book_id" {
  parent_id   = aws_api_gateway_rest_api.user_api.root_resource_id
  path_part   = "{book_id}"
  rest_api_id = aws_api_gateway_rest_api.user_api.id
}

resource "aws_api_gateway_method" "get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.book_id.id
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
}

# Create an integration with the User API Function
resource "aws_api_gateway_integration" "user_api_handler_function" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  resource_id = aws_api_gateway_resource.book_id.id
  http_method = aws_api_gateway_method.get.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.user_api_handler.invoke_arn
}

resource "aws_api_gateway_deployment" "user_api" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id

  triggers = {
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.book_id,
      aws_api_gateway_method.get,
      aws_api_gateway_integration.user_api_handler_function.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
  aws_api_gateway_resource.book_id, 
  aws_api_gateway_method.get,
  aws_api_gateway_integration.user_api_handler_function
  ]
    
}

resource "aws_api_gateway_stage" "user_api_prod" {
  deployment_id = aws_api_gateway_deployment.user_api.id
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  stage_name    = "v1"
}

resource "aws_api_gateway_method_settings" "example" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  stage_name  = aws_api_gateway_stage.user_api_prod.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "INFO"
  }
}

#
## Roles & Policy's ##
#

