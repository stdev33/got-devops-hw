variable "s3_bucket_name" {
  description = "Name of S3 bucket to save terraform state"
  type        = string
}

variable "kubeconfig" {
  description = "Path to kubeconfig file"
  type        = string
}

variable "cluster_name" {
  description = "Name of Kubernetes cluster"
  type        = string
}

variable "argocd_hostname" {
  description = "DNS hostname for ArgoCD ingress"
  type        = string
}
