variable "project_name" {
  type        = string
  description = "Name of the project."
}

variable "region" {
  type        = string
  description = "AWS region for all resources."
}

variable "books_table_name" {
  type        = string
  description = "DynamoDB table name of books_table"
}

variable "books_table_arn" {
  type        = string
  description = "DynamoDB table ARN of books_table"
}

variable "API_DOMAIN_NAME" {
  type        = string
  description = "The domain name used to access the admin API"
  sensitive = true
}

variable "DOMAIN_HOSTED_ZONE_ID" {
  type        = string
  description = "The AWS certificate used with the user api domain name"
  sensitive = true
}