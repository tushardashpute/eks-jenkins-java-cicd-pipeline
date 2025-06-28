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

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.4.0/24", "10.0.5.0/24"]
}

variable "enable_nat_gateway" {
  type = bool
  default = true
}

variable "single_nat_gateway" {
  type = bool
  default = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "toolchain-eks-cluster"
}

# EC2 instance type for worker nodes
variable "worker_instance_type" {
  type        = list(string)   # ✅ MUST be a list
  description = "List of EC2 instance types for worker nodes"
  default     = ["t3.medium"]
}

# Minimum number of nodes in the managed node group
variable "node_group_min_size" {
  type        = number
  default     = 2
  description = "Minimum number of nodes in the node group"
}

# Maximum number of nodes in the managed node group
variable "node_group_max_size" {
  type        = number
  default     = 4
  description = "Maximum number of nodes in the node group"
}

# Desired number of nodes in the managed node group
variable "node_group_desired_size" {
  type        = number
  default     = 2
  description = "Desired number of nodes in the node group"
}