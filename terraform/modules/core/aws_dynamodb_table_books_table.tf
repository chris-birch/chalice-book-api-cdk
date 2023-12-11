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


#
## SSM Parameter Outputs ##
#

resource "aws_ssm_parameter" "table_name" {
  name  = "/chalice_cdk_project/outputs/books_table/table_name"
  type  = "String"
  value = aws_dynamodb_table.books_table.name

  depends_on = [ aws_dynamodb_table.books_table ]
}

resource "aws_ssm_parameter" "table_arn" {
  name  = "/chalice_cdk_project/outputs/books_table/table_arn"
  type  = "String"
  value = aws_dynamodb_table.books_table.arn

  depends_on = [ aws_dynamodb_table.books_table ]
}