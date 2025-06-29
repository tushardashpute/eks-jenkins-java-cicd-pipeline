terraform {
  backend "s3" {
    bucket       = "mytflockstate"
    key          = "backend/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}