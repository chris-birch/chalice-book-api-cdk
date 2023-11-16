#
# Lambda function to process CSV files and bulk update the DB
#


#
## Lambda Archive ##
#

# Create ZIP archive
data "archive_file" "user_api_function_archive" {
  type = "zip"

  source_dir  = "${path.module}/lambda_function_code"
  output_path = "${path.module}/archive/user_api_code.zip"
}

# App code archive store
resource "aws_s3_bucket" "user_api_function_code" {
  bucket = "user-api-function-code-${random_id.generator.dec}"
}

# Create app code archive
resource "aws_s3_object" "user_api_function_archive" {
  bucket = aws_s3_bucket.user_api_function_code.id

  key    = "user_api_code.zip"
  source = data.archive_file.user_api_function_archive.output_path

  depends_on = [ data.archive_file.user_api_function_archive ]

}


#
## Lambda Function ##
#

resource "aws_lambda_function" "user_api_handler" {
  function_name = "${var.project_name}_user_api_${random_id.generator.id}"
  description = "Processes requests from the User API and returns data from DynamoDB"
  role          = aws_iam_role.user_api_execution_role.arn
  handler       = "bootstrap"
  architectures = ["arm64"]
  runtime = "provided.al2"

  timeout = 5
  memory_size = 128

  source_code_hash = data.archive_file.user_api_function_archive.output_base64sha256

  s3_bucket = aws_s3_bucket.user_api_function_code.id
  s3_key = aws_s3_object.user_api_function_archive.key

  environment {
    variables = {
      TABLENAME = var.books_table_name
    }
  }

  depends_on = [ 
    aws_iam_role.user_api_execution_role, 
    aws_s3_object.user_api_function_archive 
  ]
}


#
## Roles & Policy's ##
#

resource "aws_iam_role" "user_api_execution_role" {
  name        = "user_api_execution_role"
  description = "Execution role used by the User API Handler Lambda function"

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

resource "aws_lambda_permission" "user_api_execute_handler_function" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${local.account_id}:${aws_api_gateway_rest_api.user_api.id}/*/${aws_api_gateway_method.get.http_method}${aws_api_gateway_resource.book_id.path}"
}

resource "aws_iam_role_policy_attachment" "attatch_access_books_table_policy" {
  role       = aws_iam_role.user_api_execution_role.name
  policy_arn = aws_iam_policy.access_books_table.arn

  depends_on = [ aws_iam_policy.access_books_table ]
}

resource "aws_iam_role_policy_attachment" "attatch_access_cloudwatch_policy" {
  role       = aws_iam_role.user_api_execution_role.name
  policy_arn = aws_iam_policy.user_api_access_cloudwatch.arn
}