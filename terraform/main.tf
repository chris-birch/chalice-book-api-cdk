provider "aws" {
  region = var.region

    default_tags {
    tags = "${local.tags}"
  }
}

provider "random" {}


resource "random_id" "generator" {
	  byte_length = 8
}

module "core_resources" {
    source = "./modules/core"

    project_name = var.project_name
}

module "csv_processor" {
  source = "./modules/csv_processor"
  project_name = var.project_name

  depends_on = [ module.core_resources ]
}

module "user_api" {
  source = "./modules/user_api"
  project_name = var.project_name
  region = var.region
  books_table_name = module.core_resources.books_table_name
  books_table_arn = module.core_resources.books_table_arn
  depends_on = [ module.core_resources ]
  DOMAIN_HOSTED_ZONE_ID=var.DOMAIN_HOSTED_ZONE_ID
  CLIENT_DOMAIN_NAME=var.CLIENT_DOMAIN_NAME
  CLIENT_CERTIFICATE_ARN=var.CLIENT_CERTIFICATE_ARN
}

module "chalice_cdk" {
  source = "./modules/chalice_cdk"
  project_name = var.project_name
  region = var.region
  books_table_name = module.core_resources.books_table_name
  books_table_arn = module.core_resources.books_table_arn
  depends_on = [ module.core_resources ]
  DOMAIN_HOSTED_ZONE_ID=var.DOMAIN_HOSTED_ZONE_ID
  API_DOMAIN_NAME=var.API_DOMAIN_NAME
}

output "csv_bucket" {
  value = module.csv_processor.csv_bucket
}

output "user_api_invoke_url" {
  value = module.user_api.user_api_invoke_url
}