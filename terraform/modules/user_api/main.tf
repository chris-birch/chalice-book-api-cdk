resource "random_id" "generator" {
	  byte_length = 8
}

data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
}