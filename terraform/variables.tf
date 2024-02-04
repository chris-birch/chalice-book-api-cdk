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

variable "CLIENT_DOMAIN_NAME" {
  type        = string
  description = "The domain name used to access the user API"
  sensitive = true
}

variable "CLIENT_CERTIFICATE_ARN" {
  type        = string
  description = "The AWS certificate used with the user api domain name"
  sensitive = true
}

variable "DOMAIN_HOSTED_ZONE_ID" {
  type        = string
  description = "The AWS certificate used with the user api domain name"
  sensitive = true
}
