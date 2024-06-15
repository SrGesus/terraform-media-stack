provider "radarr" {
  url = module.k8s.service_ip["radarr"]
  api_key = module.k8s.api_key["radarr"]
}

resource "radarr_root_folder" "movies" {
  path = "/library"
}

resource "radarr_download_client_qbittorrent" "client" {
  enable = true
  name = "qBittorrent"
  host = module.k8s.qbit_host
  port = module.k8s.qbit_port
  username = "admin"
  password = module.k8s.qbittorrent_password
  movie_category = "radarr"
}


resource "radarr_host" "radarr" {
  launch_browser  = true
  bind_address    = "*"
  port            = 7878
  url_base        = "/radarr"
  instance_name   = "Radarr"
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