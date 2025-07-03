locals {
  oidc_thumbprint = "9e99a48a9960b14926bb7f3b02e22da0cbe3ec1d"
}

resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "AmazonEKS_EBS_CSI_DriverRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attach" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_openid_connect_provider" "oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [local.oidc_thumbprint]
  url             = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

data "aws_eks_cluster" "eks_cluster" {
  name = "lesson-7-eks-cluster"
}

data "aws_eks_cluster_auth" "eks" {
  name = data.aws_eks_cluster.eks_cluster.name
}

resource "aws_iam_role" "ebs_csi_oidc_role" {
  name = "AmazonEKS_EBS_CSI_DriverOIDCRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.oidc.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_oidc_policy" {
  role       = aws_iam_role.ebs_csi_oidc_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}