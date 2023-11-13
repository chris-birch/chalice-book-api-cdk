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