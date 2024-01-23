output "user_api_invoke_url" {
  description = "User API invoke URL"
  value       = aws_api_gateway_stage.user_api_prod.invoke_url
}