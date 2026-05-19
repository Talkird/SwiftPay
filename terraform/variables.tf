variable "region" {
  description = "Región de AWS donde se desplegará SwiftPay"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Nombre único del bucket S3 para el frontend de SwiftPay"
  type        = string
  default     = "swiftpay-frontend-app"
}

variable "terraform_state_bucket" {
  description = "Nombre único del bucket S3 para guardar el estado de Terraform"
  type        = string
  default     = "swiftpay-terraform-state-tp"
}