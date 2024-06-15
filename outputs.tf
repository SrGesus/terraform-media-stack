
output "qbittorrent_password" {
  value = module.k8s.qbittorrent_password
  sensitive = false
}

output "qbittorrent_password_hash" {
  value = module.k8s.qbittorrent_password_hash
  sensitive = false
}
