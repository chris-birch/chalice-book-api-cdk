#
# Lambda function to process CSV files and bulk update the DB
#


#
## Lambda Archive ##
#

# Define existing archive
data "aws_s3_object" "csv_processor_function_archive" {
  bucket = "github-actions-artifact-store-14z4a60uvvx3r"
  key    = "csv_processor_function_code.zip"
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

  # source_code_hash = data.aws_s3_object.csv_processor_function_archive.checksum_sha256 # Not sure why this doesn't work
  source_code_hash = base64sha256(data.aws_s3_object.csv_processor_function_archive.etag)


  s3_bucket = data.aws_s3_object.csv_processor_function_archive.bucket
  s3_key = data.aws_s3_object.csv_processor_function_archive.key

  environment {
    variables = {
      APIURL = "UPDATE_BY_SCRIPT" # <- This will be updated by 'update_terraform_asset_attributes.py'
    }
  }

  depends_on = [ 
    aws_iam_role.csv_processor_execution_role, 
    data.aws_s3_object.csv_processor_function_archive
  ]
}


#
## SSM Parameter Outputs ##
#

resource "aws_ssm_parameter" "function_name" {
  name  = "/chalice_cdk_project/outputs/csv_processor/function_name"
  type  = "String"
  value = aws_lambda_function.csv_processor.function_name

  depends_on = [ aws_lambda_function.csv_processor ]
}

resource "aws_ssm_parameter" "function_role_name" {
  name  = "/chalice_cdk_project/outputs/csv_processor/function_role_name"
  type  = "String"
  value = aws_iam_role.csv_processor_execution_role.name

  depends_on = [ aws_lambda_function.csv_processor ]
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

resource "aws_lambda_permission" "s3_execute_lambda_permission" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.csv_processor_data_store.arn
}

resource "aws_iam_role_policy_attachment" "attatch_access_csv_bucket_policy" {
  role       = aws_iam_role.csv_processor_execution_role.name
  policy_arn = aws_iam_policy.access_csv_bucket.arn

  depends_on = [ aws_iam_policy.access_csv_bucket ]
}

resource "aws_iam_role_policy_attachment" "attatch_access_cloudwatch_policy" {
  role       = aws_iam_role.csv_processor_execution_role.name
  policy_arn = aws_iam_policy.access_cloudwatch.arn
}