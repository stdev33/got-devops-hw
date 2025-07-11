output "argocd_server_url" {
  description = "URL of the Argo CD server"
  value       = "argo-cd.${var.namespace}.svc.cluster.local"
}

data "kubernetes_secret" "initial_admin" {
  metadata {
    name      = "argo-cd-initial-admin-secret"
    namespace = var.namespace
  }
}

output "argocd_initial_password" {
  description = "Initial admin password for Argo CD (decoded)"
  value       = "Run: kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d"
  #value       = try(base64decode(data.kubernetes_secret.initial_admin.data["password"]), "")
  sensitive   = true
}