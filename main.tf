terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    prowlarr = {
      source = "devopsarr/prowlarr"
    }
    radarr = {
      source = "devopsarr/radarr"
    }
    sonarr = {
      source = "devopsarr/sonarr"
    }
    lidarr = {
      source = "devopsarr/lidarr"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig
}

resource "kubernetes_namespace" "kino" {
  metadata {
    name = var.namespace
  }
}

module "deployment" {
  source               = "./deployment"
  namespace            = var.namespace
  downloads            = var.downloads
  qbittorrent_password = var.qbittorrent_password
  providers = {
    kubernetes = kubernetes
  }
  applications = {
    prowlarr = {
      library = var.downloads
    }
    radarr = {
      # Path to where the final media content is to be stored. 
      library = "~/Videos/Movies"
    }
    sonarr = {
      library = "~/Videos/Shows"
    }
    lidarr = {
      library = "~/Music"
    }
  }
}

module "provisioning" {
  source               = "./provisioning"
  namespace            = var.namespace
  routes               = module.deployment.routes
  api_keys             = module.deployment.api_keys
  username             = var.username
  password             = var.password
  qbittorrent_password = var.qbittorrent_password
  providers = {
    lidarr   = lidarr
    prowlarr = prowlarr
    radarr   = radarr
    sonarr   = sonarr
  }
}

provider "lidarr" {
  url     = "http://${module.deployment.routes.lidarr.clusterip}/lidarr"
  api_key = module.deployment.api_keys.lidarr
}

provider "prowlarr" {
  url     = "http://${module.deployment.routes.prowlarr.clusterip}/prowlarr"
  api_key = module.deployment.api_keys.prowlarr
}

provider "radarr" {
  url     = "http://${module.deployment.routes.radarr.clusterip}/radarr"
  api_key = module.deployment.api_keys.radarr
}

provider "sonarr" {
  url     = "http://${module.deployment.routes.sonarr.clusterip}/sonarr"
  api_key = module.deployment.api_keys.sonarr
}

resource "null_resource" "deployment" {
  depends_on = [
    kubernetes_namespace.kino,
    module.deployment
  ]
}
