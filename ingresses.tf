# Ingress Templates

resource "kubernetes_ingress_v1" "app_ingress_no_middleware" {
  for_each = merge(local.applications, {"prowlarr": ""})
  metadata {
    name = "${each.key}-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
    }
  }
  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = "${each.key}-web"
              port {
                number = 80
              }
            }
          }
          path = "/${each.key}/"
          path_type = "Prefix"
        }
      }
    }
  }
}

resource "kubernetes_manifest" "app_middleware" {
  for_each = toset(["jellyfin", "qbittorrent"])
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "Middleware"
    metadata = {
      name      = "${each.key}-middleware"
      namespace = var.namespace
    }
    spec = {
      stripPrefix = {
        prefixes = ["/${each.key}/"]
      }
    }
  }
}

resource "kubernetes_ingress_v1" "app_ingress" {
  for_each = toset(["jellyfin", "qbittorrent"])
  metadata {
    name = "${each.key}-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "traefik"
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web"
      "traefik.ingress.kubernetes.io/router.middlewares" = "${var.namespace}-${each.key}-middleware@kubernetescrd"
    }
  }
  spec {
    rule {
      http {
        path {
          backend {
            service {
              name = "${each.key}-web"
              port {
                number = 80
              }
            }
          }
          path = "/${each.key}/"
          path_type = "Prefix"
        }
      }
    }
  }
}


