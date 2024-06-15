## Deploy prowlarr to Kubernetes
locals {
  prowlarr_config = "${abspath(path.module)}/data/prowlarr"
}

resource "kubernetes_deployment" "prowlarr" {
  metadata {
    name      = "prowlarr"
    namespace = var.namespace
    labels = {
      "app" = "prowlarr"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app" = "prowlarr"
      }
    }
    template {
      metadata {
        labels = {
          "app" = "prowlarr"
        }
      }
      spec {
      container {
          name  = "prowlarr"
          image = "ghcr.io/linuxserver/prowlarr:latest"
          env {
            name  = "TZ"
            value = "Europe/Lisbon"
          }
          env {
            name  = "PUID"
            value = "1000"
          }
          env {
            name  = "PGID"
            value = "1000"
          }
          port {
            name           = "web"
            container_port = 9696
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
        }
        volume {
          name = "data"
          host_path {
            path = local.prowlarr_config
            type = "DirectoryOrCreate"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "prowlarr_web" {
  metadata {
    name      = "prowlarr-web"
    namespace = var.namespace
  }
  spec {
  type = "ClusterIP"
  selector = {
    "app" = "prowlarr"
  }
  port {
    name        = "web"
    port        = 80
    target_port = "web"
  }
  }
  depends_on = [
    kubernetes_deployment.prowlarr
  ]
}