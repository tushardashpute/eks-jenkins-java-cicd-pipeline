terraform {
  required_version = ">= 1.3.0"  # Updated minimum Terraform version

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.34.0"  # Latest major stable version
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.24.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.1"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.3"
    }
  }
}
