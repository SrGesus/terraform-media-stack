

data "external" "get_hash" {
  program = ["python3", "${abspath(path.module)}/qbit_hash.py", var.qbittorrent_password]
}

data "local_file" "add_password_sh" {
  filename = "${abspath(path.module)}/qbit_hash_insert.sh"
}

resource "null_resource" "reset_password" {
  triggers = {
    password_change = var.qbittorrent_password
  }
}

resource "kubernetes_deployment" "qbittorrent" {
  lifecycle {
    replace_triggered_by = [ null_resource.reset_password ]
  }
  metadata {
    name      = "qbittorrent"
    namespace = var.namespace
    labels = {
      "app" = "qbittorrent"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app" = "qbittorrent"
      }
    }
    template {
      metadata {
        labels = {
          "app" = "qbittorrent"
        }
      }
      spec {
        init_container {
          name  = "qbittorrent-init"
          image = "debian:bookworm-slim"
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
          command = ["/bin/bash", "-c"]
          args = [
            replace(data.local_file.add_password_sh.content, "$1", data.external.get_hash.result.hash)
          ]
        }
        container {
          name = "qbittorrent"
          image = "ghcr.io/linuxserver/qbittorrent"
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
          env {
            name  = "WEBUI_PORT"
            value = "80"
          }
          env {
            name  = "TORRENTING_PORT"
            value = "6881"
          }
          port {
            name           = "web"
            container_port = 80
          }
          port {
            container_port = 6881
            protocol       = "UDP"
          }
          port {
            container_port = 6881
            protocol       = "TCP"
          }
          volume_mount {
            name       = "downloads"
            mount_path = "/downloads"
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
        }
        volume {
          name = "downloads"
          host_path {
            path = pathexpand(var.downloads)
            type = "DirectoryOrCreate"
          }
        }
        volume {
          name = "data"
          host_path {
            path = "${abspath(path.module)}/data/qbit"
            type = "DirectoryOrCreate"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "qbittorrent_web" {
  metadata {
    name      = "qbittorrent-web"
    namespace = var.namespace
  }
  spec {
    type = "ClusterIP"
    selector = {
      "app" = "qbittorrent"
    }
    port {
      name        = "web"
      port        = 80
      target_port = "web"
    }
  }
  depends_on = [
    kubernetes_deployment.qbittorrent
  ]
}

resource "kubernetes_service" "qbittorrent_torrenting" {
  metadata {
    name      = "qbittorrent-torrenting"
    namespace = var.namespace
  }
  spec {
    type = "NodePort"
    selector = {
      "app" = "qbittorrent"
    }
    port {
      name        = "tcp"
      port        = 6881
      target_port = 6881
      protocol    = "TCP"
    }
    port {
      name        = "udp"
      port        = 6881
      target_port = 6881
      protocol    = "UDP"
    }
  }
  depends_on = [
    kubernetes_deployment.qbittorrent
  ]
}
