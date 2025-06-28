locals {
  # Dynamically generated cluster name with random suffix for uniqueness
  cluster_name = "eks-${random_string.suffix.result}"
}
