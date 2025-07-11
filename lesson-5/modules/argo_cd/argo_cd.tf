resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = var.helm_repo_url
  chart            = "argo-cd"
  namespace        = var.namespace
  create_namespace = true
  version          = var.chart_version
  values           = [file("${path.module}/values.yaml")]
  # optional: wait = true
}

resource "helm_release" "argocd_apps" {
  name             = "argocd-apps"
  namespace        = var.namespace
  chart            = "${path.module}/charts"
  create_namespace = false
  dependency_update = true
  values           = [file("${path.module}/charts/values.yaml")]
  depends_on       = [helm_release.argocd]
  wait             = true
}