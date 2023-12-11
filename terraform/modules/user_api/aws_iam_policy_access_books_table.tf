resource "aws_iam_policy" "access_books_table" {
  name        = "access_books_table"
  description = "Used to execute the admin API"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid": "ReadOnlyAPIActionsOnBooks",
            "Action": [
                "dynamodb:GetItem",
                "dynamodb:BatchGetItem",
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:ConditionCheckItem"
            ],
        Effect   = "Allow"
        Resource = "${var.books_table_arn}"
      }
    ]
  })
}