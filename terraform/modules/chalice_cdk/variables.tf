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