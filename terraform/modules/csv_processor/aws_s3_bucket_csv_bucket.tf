#
# S3 Bucket to store CSV files to bulk import data into the app
#

## S3 Bucket ##

# CSV Store
resource "aws_s3_bucket" "csv_processor_data_store" {
  bucket = "csv-processor-data-store-${random_id.generator.dec}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.csv_processor_data_store.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.csv_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }
}