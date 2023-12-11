locals {
  tags = {
    Terraform = "true"
    Project = "${var.project_name}"
  }
}

variable "region" {
  type        = string
  description = "AWS region for all resources."

  default = "eu-west-2"
}

variable "project_name" {
  type        = string
  description = "Name of the project."

  default = "chalice-book-api-cdk"
}
