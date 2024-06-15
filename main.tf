terraform {
  required_providers {
    prowlarr = {
      source = "devopsarr/prowlarr"
      version = "2.4.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.31.0"
    }
    radarr = {
      source = "devopsarr/radarr"
      version = "2.2.0"
    }
    sonarr = {
      source = "devopsarr/sonarr"
      version = "3.2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "/etc/rancher/k3s/k3s.yaml"
}

resource "kubernetes_namespace" "prowlarr" {
  metadata {
    name = var.namespace
  }
}

locals {
  applications = {
    radarr = {
      library = "/home/user/Downloads/Movies/Movies"
      port = 7878
    }
    sonarr = {
      library = "/home/user/Downloads/Movies/Shows"
      port = 8989
    }
  }
}

module "k8s" {
  source = "./k8s"
  namespace = var.namespace
  downloads = "/home/user/Downloads"
  applications = local.applications
  providers = {
    kubernetes = kubernetes
  }
}

resource "null_resource" "bootstrapper" {
  depends_on = [
    kubernetes_namespace.prowlarr,
    module.k8s
  ]
}

