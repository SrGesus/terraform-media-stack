## Deploy Sonarr to Kubernetes
locals {
  data_folder = {
    for key, value in var.applications : key => "${abspath(path.module)}/data/${key}"
  }
}

resource "kubernetes_deployment" "applications" {
  for_each = var.applications
  metadata {
    name      = "${each.key}"
    namespace = var.namespace
    labels = {
      "app" = "${each.key}"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app" = "${each.key}"
      }
    }
    template {
      metadata {
        labels = {
          "app" = "${each.key}"
        }
      }
      spec {
      container {
          name  = "${each.key}"
          image = "ghcr.io/linuxserver/${each.key}:latest"
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
            container_port = each.value.port
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
          volume_mount {
            name       = "library"
            mount_path = "/library"
          }
          volume_mount {
            name       = "downloads"
            mount_path = "/downloads"
          }
        }
        volume {
          name = "data"
          host_path {
            path = local.data_folder[each.key]
            type = "DirectoryOrCreate"
          }
        }
        volume {
          name = "library"
          host_path {
            path = each.value.library
            type = "DirectoryOrCreate"
          }
        }
        volume {
          name = "downloads"
          host_path {
            path = var.downloads
            type = "DirectoryOrCreate"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "applications" {
  for_each = var.applications
  metadata {
    name      = "${each.key}-web"
    namespace = var.namespace
  }
  spec {
  type = "ClusterIP"
  selector = {
    "app" = each.key
  }
  port {
    name        = "web"
    port        = 80
    target_port = "web"
  }
  }
  depends_on = [
    kubernetes_deployment.applications
  ]
}

## Sonarr Outputs
output "service_ip" {
  # value = length(kubernetes_service.sonarr_web) > 0 ? "http://${kubernetes_service.sonarr_web[0].spec.0.cluster_ip}:${kubernetes_service.sonarr_web[0].spec.0.port.0.port}" : ""
  value = {
    for key, value in kubernetes_service.applications : key => "http://${value.spec.0.cluster_ip}:${value.spec.0.port.0.port}"
  }
  sensitive = false
}

# Wait for config file to be created
resource "time_sleep" "config_delay" {
  depends_on = [ kubernetes_deployment.applications ]
  create_duration = "3s"
}
data "local_file" "config" {
  for_each = var.applications
  filename = "${local.data_folder[each.key]}/config.xml"
  depends_on = [ time_sleep.config_delay ]
}
output "api_key" {
  # value = length(data.local_file.sonarr_config) > 0 ? regex("<ApiKey>(.*)</ApiKey>", data.local_file.sonarr_config.content).0 : "none"
  value = {
    for key, value in data.local_file.config : key => regex("<ApiKey>(.*)</ApiKey>", value.content).0
  }
  sensitive = true
}
