resource "helm_release" "kubed" {
  name             = "kubed"
  repository       = "https://charts.appscode.com/stable/"
  chart            = "kubed"
  namespace        = "kubed"
  create_namespace = true
  version          = "v0.12.0"
}