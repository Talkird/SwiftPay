output "bucket_name" {
  description = "Nombre del bucket creado para el frontend"
  value       = data.aws_s3_bucket.frontend.bucket
}

output "website_url" {
  description = "URL para acceder a SwiftPay"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "terraform_state_bucket" {
  description = "Nombre del bucket para el estado de Terraform"
  value       = data.aws_s3_bucket.terraform_state.bucket
}
