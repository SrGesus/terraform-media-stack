locals {
  jellyfin_config = "${abspath(path.module)}/data/jellyfin"
}

resource "kubernetes_deployment" "jellyfin" {
  metadata {
    name      = "jellyfin"
    namespace = var.namespace
    labels = {
      "app" = "jellyfin"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        "app" = "jellyfin"
      }
    }

    template {
      metadata {
        labels = {
          "app" = "jellyfin"
        }
      }

      spec {
        container {
          name  = "jellyfin"
          image = "ghcr.io/linuxserver/jellyfin:latest"
          port {
            name           = "web"
            container_port = 8096
          }
          port {
            name           = "local-discovery"
            container_port = 7359
          }
          port {
            name           = "dlna"
            container_port = 1900
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
          dynamic "volume_mount" {
            for_each = var.applications
            content {
              name       = lower(regex("[^/]+$", volume_mount.value.library))
              mount_path = "/data/${lower(regex("[^/]+$", volume_mount.value.library))}"
            }
            
          }
        }
        volume {
          name = "data"
          host_path {
            path = local.jellyfin_config
            type = "DirectoryOrCreate" 
          }
        }
        dynamic "volume" {
          for_each = var.applications
          content {
            name = lower(regex("[^/]+$", volume.value.library))
            host_path {
              path = volume.value.library
              type = "DirectoryOrCreate"
            }
          }
        }
      }
    }
  }
}


# Jellyfin routing
resource "kubernetes_service" "jellyfin_web" {
  metadata {
    name      = "jellyfin-web"
    namespace = var.namespace
  }
  spec {
  type = "ClusterIP"
  selector = {
    "app" = "jellyfin"
  }
  port {
    name        = "web"
    port        = 80
    target_port = 8096
  }
  }
  depends_on = [
    kubernetes_deployment.jellyfin
  ]
}

resource "kubernetes_service" "jellyfin_discovery" {
  metadata {
    name      = "jellyfin-local-discovery"
    namespace = var.namespace
  }
  spec {
    type = "NodePort"
    selector = {
      "app" = "jellyfin"
    }
    port {
      name        = "local-discovery"
      port        = 7359
      target_port = "local-discovery"
    }
    port {
      name        = "dlna"
      port        = 1900
      target_port = "dlna"
    }
  }
}

