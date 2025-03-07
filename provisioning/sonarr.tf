resource "sonarr_root_folder" "movies" {
  path       = "/library"
}

resource "sonarr_download_client_qbittorrent" "client" {
  enable      = true
  name        = "qBittorrent"
  host        = replace(var.routes.qbittorrent.url, "http://", "")
  port        = 80
  username    = "admin"
  password    = var.qbittorrent_password
  tv_category = "sonarr"
  remove_completed_downloads = true
}

resource "sonarr_host" "sonarr" {
  launch_browser  = true
  bind_address    = "*"
  port            = 80
  url_base        = "/sonarr"
  instance_name   = "Sonarr"
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
    log_level         = "info"
    analytics_enabled = true
    log_size_limit    = 1
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

# # Restart Radarr when settings change because the provider doesn't seem to do it automatically
# resource "null_resource" "sonarr_restart" {
#   provisioner "local-exec" {
#     command = "curl -X POST ${module.k8s.service_ip["sonarr"]}/api/v3/system/restart?apikey=${module.k8s.api_key["sonarr"]}"
#   }
#   depends_on = [ sonarr_host.sonarr ]
# }

