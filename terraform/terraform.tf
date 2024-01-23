terraform {
  required_version = "~> 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
        archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
  /* Uncomment this block to use Terraform Cloud
  cloud {
    organization = "organization-name"
    workspaces {
      name = "learn-terraform-init"
    }
  }
*/
}