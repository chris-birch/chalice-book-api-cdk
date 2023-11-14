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
        Resource = "arn:aws:dynamodb:eu-west-2:599106691906:table/chalice-cdk-project-files-AppTable815C50BC-1D2JPYHQ9LZCJ"
      }
    ]
  })
}