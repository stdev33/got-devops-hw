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
  bucket_name = var.s3_bucket_name
  table_name  = "terraform-locks"
}

module "vpc" {
  source             = "./modules/vpc"
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  vpc_name           = "final-project-vpc"
}

module "ecr" {
  source       = "./modules/ecr"
  ecr_name     = "final-project-ecr"
  scan_on_push = true
}

module "eks" {
  source           = "./modules/eks"
  cluster_name     = var.cluster_name
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

module "argo_cd" {
  source            = "./modules/argo_cd"
  cluster_name      = module.eks.cluster_name
  server_ingress_host = var.argocd_hostname
  namespace    = "argocd"
  chart_version = "5.46.4"
}

module "rds" {
  source = "./modules/rds"

  name                       = "myapp-db"
  use_aurora                 = false
  aurora_instance_count      = 2

  # --- Aurora-only ---
  engine_cluster             = "aurora-postgresql"
  engine_version_cluster     = "15.3"
  parameter_group_family_aurora = "aurora-postgresql15"

  # --- RDS-only ---
  engine                     = "postgres"
  engine_version             = "17.2"
  parameter_group_family_rds = "postgres17"

  # Common
  instance_class             = "db.t3.medium"
  allocated_storage          = 5
  db_name                    = "myapp"
  username                   = "postgres"
  password                   = "admin123AWS23"
  subnet_private_ids         = module.vpc.private_subnet_ids
  subnet_public_ids          = module.vpc.public_subnet_ids
  publicly_accessible        = true
  vpc_id                     = module.vpc.vpc_id
  multi_az                   = true
  backup_retention_period    = 7
  parameters = {
    max_connections              = "200"
    log_min_duration_statement   = "500"
  }

  tags = {
    Environment = "dev"
    Project     = "myapp"
  }
} 
