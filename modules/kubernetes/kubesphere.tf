data "kubectl_path_documents" "manifests" {
  pattern = "${abspath(path.module)}/manifests/*.yaml"
}

resource "kubectl_manifest" "kubesphere" {
  //noinspection HILUnresolvedReference
  for_each = toset(data.kubectl_path_documents.manifests.documents)
  yaml_body = each.value
}
resource "kubernetes_ingress_v1" "kubesphere" {
  depends_on = [kubectl_manifest.kubesphere]
  metadata {
    name = "ks-console"
    namespace = "kubesphere-system"
  }
  spec {
    rule {
      host = "sphere.${var.domain}"
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "ks-console"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}