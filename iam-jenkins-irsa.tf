data "aws_iam_policy_document" "jenkins_irsa_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider_arn, "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/", "")}:sub"
      values   = ["system:serviceaccount:jenkins:jenkins"]
    }
  }
}

data "aws_iam_policy_document" "ecr_access_policy" {
  statement {
    sid = "AllowECRActions"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role" "jenkins_irsa_role" {
  name = "jenkins-irsa-role"

  assume_role_policy = data.aws_iam_policy_document.jenkins_irsa_assume_role_policy.json

  tags = {
    app = "jenkins"
  }
}

resource "aws_iam_policy" "jenkins_ecr_policy" {
  name   = "jenkins-ecr-policy"
  policy = data.aws_iam_policy_document.ecr_access_policy.json
}

resource "aws_iam_role_policy_attachment" "jenkins_ecr_attach" {
  role       = aws_iam_role.jenkins_irsa_role.name
  policy_arn = aws_iam_policy.jenkins_ecr_policy.arn
}
