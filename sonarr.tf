provider "sonarr" {
  url = module.k8s.service_ip["sonarr"]
  api_key = module.k8s.api_key["sonarr"]
}

resource "sonarr_root_folder" "shows" {
  path = "/library"
}

resource "sonarr_download_client_qbittorrent" "client" {
  enable = true
  name = "qBittorrent"
  host = module.k8s.qbit_host
  port = module.k8s.qbit_port
  username = "admin"
  password = module.k8s.qbittorrent_password
  tv_category = "sonarr"
}

resource "sonarr_host" "sonarr" {
  launch_browser  = true
  bind_address    = "*"
  port            = 8989
  url_base        = "/sonarr"
  instance_name   = "Sonarr"
  application_url = ""
  
  authentication = {
    method   = "basic"
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
  }
  backup = {
    folder    = "Backups"
    interval = 7
    retention = 28
  }
  update = {
    mechanism = "docker"
    branch    = "master"
  }
}
