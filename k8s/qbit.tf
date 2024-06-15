## Deploy qbittorrent to Kubernetes
locals {
  qbittorrent_config = "${abspath(path.module)}/data/qbittorrent"
}

resource "random_string" "qbittorrent" {
  length = 16
  special = false
}

data "external" "get_hash" {
  program = ["python3", "${abspath(path.module)}/qbit/hash.py", random_string.qbittorrent.result]
  depends_on = [ random_string.qbittorrent ]
}

output "qbittorrent_password" {
  value = random_string.qbittorrent.result
  sensitive = false
}

output "qbittorrent_password_hash" {
  value = data.external.get_hash.result.hash
  sensitive = false
}

resource "null_resource" "qbittorrent_reset_password" {
  provisioner "local-exec" {
    command = "./reset_password.sh ${abspath(path.module)}/data/qbittorrent/qBittorrent"
    when = destroy
    working_dir = "${abspath(path.module)}/qbit/"
    interpreter = [ "bash", "-c" ]
  }
  lifecycle {
    replace_triggered_by = [ random_string.qbittorrent  ]
  }
  depends_on = [ random_string.qbittorrent ]
}

resource "null_resource" "qbittorrent_add_hash" {
  provisioner "local-exec" {
    command = "./add_password.sh ${abspath(path.module)}/data/qbittorrent/qBittorrent ${data.external.get_hash.result.hash}"
    working_dir = "${abspath(path.module)}/qbit/"
    when = create
    interpreter = [ "bash", "-c" ]
  }
  triggers = {
    hash = data.external.get_hash.result.hash
  }
}

resource "kubernetes_deployment" "qbittorrent" {
  lifecycle {
    replace_triggered_by = [ null_resource.qbittorrent_reset_password, null_resource.qbittorrent_add_hash ]
  }
  depends_on = [ null_resource.qbittorrent_reset_password, null_resource.qbittorrent_add_hash ]
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
      container {
          name  = "qbittorrent"
          image = "ghcr.io/linuxserver/qbittorrent:latest"
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
            name = "WEBUI_PORT"
            value = "80"
          }
          env {
            name = "TORRENTING_PORT"
            value = "6881"
          }
          env {
            name = "DEFAULT_PASSWORD_PBKDF2"
            value = data.external.get_hash.result.hash
          }
          port {
            name           = "web"
            container_port = 80
          }
          port {
            container_port = 6881
            protocol = "UDP"
          }
          port {
            container_port = 6881
            protocol = "TCP"
          }
          volume_mount {
            name       = "data"
            mount_path = "/config"
          }
          volume_mount {
            name       = "downloads"
            mount_path = "/downloads"
          }
        }
        volume {
          name = "data"
          host_path {
            path = local.qbittorrent_config
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


output "qbit_host" {
  // value = "http://${kubernetes_service.qbittorrent_web.metadata.0.name}.${var.namespace}.svc.cluster.local"
  // value = "https://${kubernetes_service.qbittorrent_web.spec.0.cluster_ip}:${kubernetes_service.qbittorrent_web.spec.0.port["web"].port}"
  value = kubernetes_service.qbittorrent_web.spec.0.cluster_ip
}

output "qbit_port" {
  value = kubernetes_service.qbittorrent_web.spec.0.port.0.port
}
