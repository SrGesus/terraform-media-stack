resource "lidarr_root_folder" "music" {
  name                    = "Music"
  quality_profile_id      = 1
  metadata_profile_id     = 1
  monitor_option          = "future"
  new_item_monitor_option = "all"
  path                    = "/library"
  tags                    = []
}

resource "lidarr_download_client_qbittorrent" "client" {
  enable         = true
  name           = "qBittorrent"
  host           = replace(var.routes.qbittorrent.url, "http://", "")
  port           = 80
  username       = "admin"
  password       = var.qbittorrent_password
  music_category = "lidarr"
  remove_completed_downloads = true
}

resource "lidarr_host" "lidarr" {
  launch_browser  = true
  bind_address    = "*"
  port            = 80
  url_base        = "/lidarr"
  instance_name   = "Lidarr"
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

# # Restart Lidarr when settings change because the provider doesn't seem to do it automatically
# resource "null_resource" "lidarr_restart" {
#   provisioner "local-exec" {
#     command = "curl -X POST ${module.k8s.service_ip["lidarr"]}/api/v3/system/restart?apikey=${module.k8s.api_key["lidarr"]}"
#   }
#   depends_on = [ lidarr_host.lidarr ]
# }

