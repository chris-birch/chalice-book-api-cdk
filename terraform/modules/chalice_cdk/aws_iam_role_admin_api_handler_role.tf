resource "aws_iam_role" "admin_api_handler" {
  name = "admin_api_handler"
  description = "Attatched to the Chalice API Lambda Handler as the default role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attatch_access_cloudwatch_policy_admin_api" {
  role       = aws_iam_role.admin_api_handler.name
  policy_arn = aws_iam_policy.admin_api_access_cloudwatch.arn
}

resource "aws_iam_role_policy_attachment" "attatch_access_books_table_policy_admin_api" {
  role       = aws_iam_role.admin_api_handler.name
  policy_arn = aws_iam_policy.access_books_table_ReadWrite.arn
}

resource "aws_ssm_parameter" "admin_api_role_arn" {
  name  = "/chalice_cdk_project/outputs/api_handler/role_arn"
  type  = "String"
  value = aws_iam_role.admin_api_handler.arn

  depends_on = [ aws_iam_role.admin_api_handler ]
}