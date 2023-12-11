resource "aws_iam_policy" "access_books_table_ReadWrite" {
  name        = "access_books_table_ReadWrite"
  description = "Used to execute the admin API"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid": "ReadOnlyAPIActionsOnBooks",
            "Action": [
                "dynamodb:BatchGetItem",
                "dynamodb:BatchWriteItem",
                "dynamodb:ConditionCheckItem",
                "dynamodb:PutItem",
                "dynamodb:DescribeTable",
                "dynamodb:DeleteItem",
                "dynamodb:GetItem",
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:UpdateItem"
            ],
        Effect   = "Allow"
        Resource = "${var.books_table_arn}"
      }
    ]
  })
}

