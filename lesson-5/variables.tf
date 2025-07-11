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
