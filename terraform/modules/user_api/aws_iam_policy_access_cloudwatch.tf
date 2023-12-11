resource "aws_iam_policy" "user_api_access_cloudwatch" {
  name        = "user_api_access_cloudwatch"
  description = "Used to access Cloudwatch"
  path        = "/"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
  })
}