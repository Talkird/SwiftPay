terraform {
  backend "s3" {
    bucket       = "swiftpay-terraform-state-tp"
    key          = "swiftpay/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
