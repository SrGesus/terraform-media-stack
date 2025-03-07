variable "api_keys" {
  sensitive = true
}

variable "namespace" {
}

variable "routes" {
}

variable "username" {
  description = "Servarr applications username."
  sensitive = true
  type = string
}

variable "password" {
  description = "Servarr applications password."
  sensitive = true
  type = string
}

variable "qbittorrent_password" {
  type = string
  sensitive = true
}
