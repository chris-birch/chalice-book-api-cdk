output "books_table_name" {
  value = aws_dynamodb_table.books_table.name
  description = "DynamoDB table name of books_table"
}

output "books_table_arn" {
  value = aws_dynamodb_table.books_table.arn
  description = "DynamoDB table ARN of books_table"
}