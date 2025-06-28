# "Generates a random 8-character string to suffix the EKS cluster name"
resource "random_string" "suffix" {
  length      = 8
  special     = false
}
