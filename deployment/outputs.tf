# Wait for config file to be created
resource "time_sleep" "config_delay" {
  depends_on      = [kubernetes_deployment.applications]
  create_duration = "10s"
}

data "local_file" "applications_config" {
  for_each   = var.applications
  filename   = "${local.data_folder[each.key]}/config.xml"
  depends_on = [time_sleep.config_delay]
}

# Read api keys from configs
output "api_keys" {
  value = {
    for key, value in data.local_file.applications_config : key => regex("<ApiKey>(.*)</ApiKey>", value.content).0
  }
  sensitive = true
}

output "namespace" {
  value = var.namespace
}

output "routes" {
  value = merge({
    for key, value in var.applications : key => {
      "route" = key
      "url" = "http://${key}-web.${var.namespace}"
      "clusterip" = kubernetes_service.applications[key].spec.0.cluster_ip
      "stripprefix" = true
    }
  },{
    for value in ["jellyfin", "qbittorrent"] : value => {
      "route" = value
      "url" = "http://${value}-web.${var.namespace}"
      "stripprefix" = false
    }
  })
  sensitive = true
}