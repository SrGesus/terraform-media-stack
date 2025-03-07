resource "prowlarr_application_radarr" "radarr" {
  name         = "Radarr"
  sync_level   = "fullSync"
  base_url     = var.routes["radarr"].url
  api_key      = var.api_keys["radarr"]
  prowlarr_url =  var.routes["prowlarr"].url
}

resource "prowlarr_application_sonarr" "sonarr" {
  name         = "Sonarr"
  sync_level   = "fullSync"
  base_url     = var.routes["sonarr"].url
  api_key      = var.api_keys["sonarr"]
  prowlarr_url =  var.routes["prowlarr"].url
}

resource "prowlarr_application_lidarr" "lidarr" {
  name         = "Lidarr"
  sync_level   = "fullSync"
  base_url     = var.routes["lidarr"].url
  api_key      = var.api_keys["lidarr"]
  prowlarr_url =  var.routes["prowlarr"].url
}

resource "prowlarr_host" "prowlarr" {
  launch_browser  = true
  bind_address    = "*"
  port            = 80
  url_base        = "/prowlarr"
  instance_name   = "Prowlarr"
  application_url = ""

  authentication = {
    method   = "forms"
    required = "enabled"
    username = var.username
    password = var.password
  }
  proxy = {
    enabled = false
  }
  ssl = {
    enabled                = false
    certificate_validation = "enabled"
  }
  logging = {
    log_level = "info"
    analytics_enabled = true
    log_size_limit = 1
  }
  backup = {
    folder    = "Backups"
    interval  = 7
    retention = 28
  }
  update = {
    mechanism = "docker"
    branch    = "master"
  }
}

# # Restart Prowlarr when settings change because the provider doesn't seem to do it automatically
# resource "null_resource" "prowlarr_restart" {
#   provisioner "local-exec" {
#     command = "curl -X POST http://localhost/prowlarr/api/v1/system/restart?apikey=${var.api_keys["prowlarr"]}"
#   }
#   depends_on = [prowlarr_host.prowlarr]
# }

