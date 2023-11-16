resource "aws_iam_policy" "access_admin_api" {
  name        = "access_admin_api"
  description = "Used to execute the admin API"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
            "Action": [
                "execute-api:Invoke",
                "execute-api:ManageConnections"
            ],
        Effect   = "Allow"
        Resource = "arn:aws:lambda:eu-west-2:599106691906:function:chalice-cdk-project-files-APIHandler-oodP32obQvFe" # <- Update this value after deploy
      }
    ]
  })
}