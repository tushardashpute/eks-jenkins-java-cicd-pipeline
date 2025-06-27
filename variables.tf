# Kubernetes version for EKS cluster
variable "kubernetes_version" {
  type        = string
  default     = "1.31"
  description = "Kubernetes version to deploy in EKS"
}

# VPC CIDR block
variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block for the VPC"
}

# AWS region for resource deployment
variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region where resources will be created"
}
