#
# Lambda function to process CSV files and bulk update the DB
#


#
## Lambda Archive ##
#

# Create ZIP archive
data "archive_file" "function_archive" {
  type = "zip"

  source_dir  = "${path.module}/lambda_function_code"
  output_path = "${path.module}/archive/csv_processor_code.zip"
}

# App code archive store
resource "aws_s3_bucket" "csv_processor_function_code" {
  bucket = "csv-processor-function-code-${random_id.generator.dec}"
}

# Create app code archive
resource "aws_s3_object" "csv_processor_function_archive" {
  bucket = aws_s3_bucket.csv_processor_function_code.id

  key    = "csv_processor_code.zip"
  source = data.archive_file.function_archive.output_path

  depends_on = [ data.archive_file.function_archive ]

}


#
## Lambda Function ##
#

resource "aws_lambda_function" "csv_processor" {
  function_name = "${var.project_name}_csv_processor_${random_id.generator.id}"
  description = "Process CSV files sent from S3 as an event to bulk import to DynamoDB via the Admin API"
  role          = aws_iam_role.csv_processor_execution_role.arn
  handler       = "bootstrap"
  architectures = ["arm64"]
  runtime = "provided.al2"

  timeout = 5
  memory_size = 128

  source_code_hash = data.archive_file.function_archive.output_base64sha256

  s3_bucket = aws_s3_bucket.csv_processor_function_code.id
  s3_key = aws_s3_object.csv_processor_function_archive.key

  environment {
    variables = {
      APIURL = "https://79ciii9fu7.execute-api.eu-west-2.amazonaws.com/api/books"
    }
  }

  depends_on = [ 
    aws_iam_role.csv_processor_execution_role, 
    aws_s3_object.csv_processor_function_archive 
  ]
}


#
## Roles & Policy's ##
#

resource "aws_iam_role" "csv_processor_execution_role" {
  name        = "csv_processor_execution_role"
  description = "Execution role used by the CSV Processor Lambda function"

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

resource "aws_iam_role_policy_attachment" "attatch_access_csv_bucket_policy" {
  role       = aws_iam_role.csv_processor_execution_role.name
  policy_arn = aws_iam_policy.access_csv_bucket.arn

  depends_on = [ aws_iam_policy.access_csv_bucket ]
}

resource "aws_iam_role_policy_attachment" "attatch_access_admin_api_policy" {
  role       = aws_iam_role.csv_processor_execution_role.name
  policy_arn = aws_iam_policy.access_admin_api.arn

  depends_on = [ aws_iam_policy.access_admin_api ]
}

resource "aws_iam_role_policy_attachment" "attatch_access_cloudwatch_policy" {
  role       = aws_iam_role.csv_processor_execution_role.name
  policy_arn = aws_iam_policy.access_cloudwatch.arn
}

resource "aws_lambda_permission" "s3_execute_lambda_permission" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.csv_processor_data_store.arn
}