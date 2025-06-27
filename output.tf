output "cluster_id" {
  description = "EKS cluster ID."
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group IDs attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider associated with the EKS cluster."
  value       = module.eks.oidc_provider_arn
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = aws_ecr_repository.springboot_app.repository_url
}

output "jenkins_irsa_role_arn" {
  description = "IAM Role ARN associated with the Jenkins service account via IRSA"
  value       = aws_iam_role.jenkins_irsa_role.arn
}
