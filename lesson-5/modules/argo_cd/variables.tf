variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "name" {
  description = "Назва Helm-релізу"
  type        = string
  default     = "argo-cd"
}

variable "namespace" {
  type        = string
  default     = "argocd"
  description = "Namespace for Argo CD"
}

variable "chart_version" {
  type        = string
  default     = "5.46.4"
  description = "Argo CD Helm chart version"
}

variable "helm_repo_url" {
  type        = string
  default     = "https://argoproj.github.io/argo-helm"
  description = "Helm repository URL for Argo CD"
}

variable "server_ingress_host" {
  type        = string
  description = "DNS hostname for Argo CD server"
}