resource "aws_iam_policy" "access_csv_bucket" {
  name        = "access_csv_bucket"
  description = "Used to access the CSV S3 bucket"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
			"s3:GetObject"
        ]
        Effect   = "Allow"
        Resource = [
          "${aws_s3_bucket.csv_processor_data_store.arn}",
          "${aws_s3_bucket.csv_processor_data_store.arn}/*"
          ]
      }
    ]
  })

  depends_on = [ aws_s3_bucket.csv_processor_data_store ]
}