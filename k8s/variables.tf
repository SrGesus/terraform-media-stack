
variable "namespace" {
  description = "The name of the namespace for the services."
  type        = string
  default = "prowlarr"
}

variable "downloads" {
  description = "The path to the Downloads Directory."
  type        = string
}

variable "applications" {
  description = "The applications to be deployed, e.g. radarr, sonarr; the path to their library, and their port."
  type = map(object({
    library = string
    port = number
  }))
  default = {
    radarr = {
      library = "/home/user/Downloads/Movies/Movies"
      port = 7878
    }
    sonarr = {
      library = "/home/user/Downloads/Movies/Shows"
      port = 8989
    }
    lidarr = {
      library = "/home/user/Downloads/Music"
      port = 8686
    }
    readarr = {
      library = "/home/user/Downloads/Books"
      port = 8787
    }
  }
}
