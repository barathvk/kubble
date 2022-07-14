terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.5.1"
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
    
    {
      name = "main"
      port = 60001
    },
    
  ]
}


  module "main_cluster" {
    source = "../modules/cluster"
    cluster_name = "main"
    cluster_port = 60001
  }
  provider "helm" {
    alias = "main"
    kubernetes {
      client_certificate     = module.main_cluster.credentials.client_certificate
      client_key             = module.main_cluster.credentials.client_key
      cluster_ca_certificate = module.main_cluster.credentials.cluster_ca_certificate
      host                   = module.main_cluster.credentials.endpoint
    }
  }
  provider "kubernetes" {
    alias = "main"
    client_certificate     = module.main_cluster.credentials.client_certificate
    client_key             = module.main_cluster.credentials.client_key
    cluster_ca_certificate = module.main_cluster.credentials.cluster_ca_certificate
    host                   = module.main_cluster.credentials.endpoint
  }
  module "main_kubernetes" {
    depends_on = [module.main_cluster]
    source = "../modules/kubernetes"
    domain = "main.localhost"
    providers = {
      helm = helm.main
      kubernetes = kubernetes.main
    }
  }
