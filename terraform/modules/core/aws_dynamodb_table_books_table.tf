#
# Create a DynamoDB table which will be used to store API data
# 

# Main DynamoDB table which will be used to store all book data
resource "aws_dynamodb_table" "books_table" {
  name           = "${var.project_name}_books_table_${random_id.generator.id}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "pk"

  attribute {
    name = "pk"
    type = "S"
  }
}