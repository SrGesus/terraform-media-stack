provider "prowlarr" {
  url = module.k8s.prowlarr_service_ip
  api_key = module.k8s.prowlarr_api_key
}

resource "prowlarr_application_radarr" "radarr" {
    name = "Radarr"
    sync_level = "fullSync"
    base_url = module.k8s.service_ip["radarr"]
    api_key = module.k8s.api_key["radarr"]
    prowlarr_url = module.k8s.prowlarr_service_ip
}

resource "prowlarr_application_sonarr" "sonarr" {
    name = "Sonarr"
    sync_level = "fullSync"
    base_url = module.k8s.service_ip["sonarr"]
    api_key = module.k8s.api_key["sonarr"]
    prowlarr_url = module.k8s.prowlarr_service_ip
}


resource "prowlarr_host" "prowlarr" {
  depends_on = [ prowlarr_application_radarr.radarr, prowlarr_application_sonarr.sonarr ]
  launch_browser  = true
  bind_address    = "*"
  port            = 9696
  url_base        = "/prowlarr"
  instance_name   = "Prowlarr"
  application_url = ""
  
  authentication = {
    method   = "basic"
    required = "disabledForLocalAddresses"
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
    branch    = "main"
  }
}

# Restart Prowlarr when settings change because the provider doesn't seem to do it automatically
resource "null_resource" "prowlarr_restart" {
  provisioner "local-exec" {
    command = "curl -X POST ${module.k8s.prowlarr_service_ip}/api/v1/system/restart?apikey=${module.k8s.prowlarr_api_key}"
  }
  depends_on = [ prowlarr_host.prowlarr ]
}

