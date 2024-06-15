
# For convinience, might change method later
output "qbittorrent_login" {
  value = {
    "username": "admin"
    "password": module.k8s.qbittorrent_password
  }
}

output "urls" {
  value = {
    "prowlarr": "http://localhost/prowlarr/"
    "radarr": "http://localhost/radarr/"
    "sonarr": "http://localhost/sonarr/"
    "jellyfin": "http://localhost/jellyfin/"
    "qbittorrent": "http://localhost/qbittorrent/"
  }
}
