variable "kubeconfig" {
  description = "The path to the kubernetes configuration"
  type    = string
  default = "~/.kube/config"
}

variable "username" {
  description = "Username for servarr applications."
  type        = string
}

variable "password" {
  description = "Password for servarr applications."
  type        = string
}

variable "movies" {
  description = "The absolute path to the directory that will be containing Movies"
  type        = string
}

variable "shows" {
  description = "The absolute path to the directory that will be containing Shows"
  type        = string
}

variable "downloads" {
  description = "The absolute path used by qbittorrent for downloads."
  type        = string
}

variable "namespace" {
  description = "Name of the namespace to deploy the applications"
  type        = string
  default     = "prowlarr"
}

