//noinspection HILUnresolvedReference
locals {
  certs_path = "${path.root}/certs"
  domains = join(" ", [for sub in var.clusters : "${sub.name}.localhost"])
  subdomains = join(" ", [for sub in var.clusters : "*.${sub.name}.localhost"])
}
resource "null_resource" "certs" {
  triggers = {
    domains = local.domains
    subdomains = local.subdomains
  }
  provisioner "local-exec" {
    command = <<EOF
      rm -rf ${local.certs_path}
      mkdir -p ${local.certs_path} &&
      mkcert \
        -install \
        -key-file=${local.certs_path}/tls.key \
        -cert-file=${local.certs_path}/tls.crt \
        localhost \
        ${local.domains} \
        ${local.subdomains}
    EOF
  }
}
data "local_file" "tls_key" {
  filename = "${local.certs_path}/tls.key"
  depends_on = [
    null_resource.certs
  ]
}
data "local_file" "tls_crt" {
  filename = "${local.certs_path}/tls.crt"
  depends_on = [
    null_resource.certs
  ]
}
