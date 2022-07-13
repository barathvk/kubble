resource "kind_cluster" "this" {
  wait_for_ready  = true
  name            = var.cluster_name
  kubeconfig_path = pathexpand("~/.kube/config")
  //noinspection HCLUnknownBlockType
  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"
    //noinspection HCLUnknownBlockType
    node {
      role = "control-plane"
      kubeadm_config_patches = [
        <<EOF
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
        EOF
      ]
      //noinspection HCLUnknownBlockType
      extra_port_mappings {
        container_port = 80
        host_port      = var.cluster_port
      }
    }
    //noinspection HCLUnknownBlockType
    node {
      role = "worker"
    }
  }
}