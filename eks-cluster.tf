module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = var.kubernetes_version

  cluster_addons = {
    coredns                = {}
    kube-proxy             = {}
    vpc-cni                = {}
    eks-pod-identity-agent = {}
    aws-ebs-csi-driver     = {
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
  }

  enable_irsa = true

  cluster_endpoint_public_access             = true
  enable_cluster_creator_admin_permissions   = true

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    ami_type               = "AL2023_x86_64_STANDARD"
    instance_types         = ["t3.medium"]
    vpc_security_group_ids = [aws_security_group.all_worker_mgmt.id]
  }

  eks_managed_node_groups = {
    node_group = {
      min_size     = 2
      max_size     = 6
      desired_size = 2
    }
  }

  tags = {
    environment = "dev"
    owner       = "toolchain-challenge"
  }
}

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.0"

  create_role                   = true
  role_name                     = "${local.cluster_name}-ebs-csi-driver"
  provider_url                  = module.eks.cluster_oidc_issuer_url
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]

  role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ]

  tags = {
    environment = "dev"
    owner       = "toolchain-challenge"
  }
}

resource "null_resource" "make_gp2_default" {
  depends_on = [module.eks] # Wait until cluster is ready

  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig --name ${local.cluster_name} --region ${var.aws_region}
      kubectl annotate storageclass gp2 storageclass.kubernetes.io/is-default-class="true" --overwrite
    EOT
  }
}
