data "aws_eks_cluster" "eks" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

module "s3_backend" {
  source      = "./modules/s3-backend"
  bucket_name = "goit-devops-hw-state-20250708"
  table_name  = "terraform-locks"
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_name           = "lesson-5-vpc"
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "lesson-5-ecr"
  scan_on_push = true
}

module "eks" {
  source           = "./modules/eks"
  cluster_name     = "lesson-7-eks-cluster"
  subnet_ids       = module.vpc.private_subnet_ids
  node_instance_profile_name = "eksNodeGroupRole"
  node_role_name   = "eksNodeGroupRole"
  cluster_role_name   = "eksClusterRole"
  cluster_role_arn = "arn:aws:iam::121905340549:role/eksClusterRole"
  node_role_arn    = "arn:aws:iam::121905340549:role/eksNodeGroupRole"
  region           = "us-west-2"
  oidc_provider_url = null
  oidc_provider_arn = null
}

module "iam_ebs_csi" {
  source = "./modules/iam-ebs-csi"

  cluster_oidc_issuer = module.eks.cluster_oidc_issuer
  oidc_provider_arn   = module.eks.oidc_provider_arn
  oidc_provider_url   = module.eks.oidc_provider_url
}

module "jenkins" {
  source       = "./modules/jenkins"
  cluster_name = module.eks.eks_cluster_name
  kubeconfig    = var.kubeconfig

  providers = {
    helm = helm
    kubernetes = kubernetes
  }
}