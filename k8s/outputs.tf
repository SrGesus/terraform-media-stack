## Prowlarr
output "prowlarr_service_ip" {
  value = "http://${kubernetes_service.prowlarr_web.spec.0.cluster_ip}:${kubernetes_service.prowlarr_web.spec.0.port.0.port}"
  sensitive = false
}

# Wait for config file to be created
resource "time_sleep" "prowlarr_config_delay" {
  depends_on = [ kubernetes_deployment.prowlarr ]
  create_duration = "3s"
}
data "local_file" "prowlarr_config" {
  filename = "${local.prowlarr_config}/config.xml"
  depends_on = [ time_sleep.prowlarr_config_delay ]
}
output "prowlarr_api_key" {
  value = regex("<ApiKey>(.*)</ApiKey>", data.local_file.prowlarr_config.content).0
  sensitive = true
}
