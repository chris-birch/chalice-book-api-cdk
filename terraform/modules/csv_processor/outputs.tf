output "csv_bucket" {
  description = "CSV processor bucket name"
  value       = aws_s3_bucket.csv_processor_data_store.id
}
