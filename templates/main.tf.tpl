terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.5.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    kind = {
      source  = "tehcyx/kind"
      version = "0.0.12"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.18.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }
  }
}
module "caddy" {
  source = "../modules/caddy"
  clusters = [
    {{ range $ix, $cluster := .clusters}}
    {
      name = "{{ $cluster }}"
      port = {{ add $.base_port $ix 1 }}
    },
    {{ end }}
  ]
}

{{ range $ix, $cluster := .clusters}}
  module "{{ $cluster }}_cluster" {
    source = "../modules/cluster"
    cluster_name = "{{ $cluster }}"
    cluster_port = {{ add $.base_port $ix 1 }}
  }
  provider "helm" {
    alias = "{{ $cluster }}"
    kubernetes {
      client_certificate     = module.{{ $cluster }}_cluster.credentials.client_certificate
      client_key             = module.{{ $cluster }}_cluster.credentials.client_key
      cluster_ca_certificate = module.{{ $cluster }}_cluster.credentials.cluster_ca_certificate
      host                   = module.{{ $cluster }}_cluster.credentials.endpoint
    }
  }
  provider "kubectl" {
    alias = "{{ $cluster }}"
    client_certificate     = module.{{ $cluster }}_cluster.credentials.client_certificate
    client_key             = module.{{ $cluster }}_cluster.credentials.client_key
    cluster_ca_certificate = module.{{ $cluster }}_cluster.credentials.cluster_ca_certificate
    host                   = module.{{ $cluster }}_cluster.credentials.endpoint
  }
  provider "kubernetes" {
    alias = "{{ $cluster }}"
    client_certificate     = module.{{ $cluster }}_cluster.credentials.client_certificate
    client_key             = module.{{ $cluster }}_cluster.credentials.client_key
    cluster_ca_certificate = module.{{ $cluster }}_cluster.credentials.cluster_ca_certificate
    host                   = module.{{ $cluster }}_cluster.credentials.endpoint
  }
  module "{{ $cluster }}_kubernetes" {
    depends_on = [module.{{ $cluster }}_cluster]
    source = "../modules/kubernetes"
    domain = "{{ $cluster }}.localhost"
    providers = {
      helm = helm.{{ $cluster }}
      kubectl = kubectl.{{ $cluster }}
      kubernetes = kubernetes.{{ $cluster }}
    }
  }
{{ end }}