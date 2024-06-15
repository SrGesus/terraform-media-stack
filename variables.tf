variable "namespace" {
  description = "Name of the namespace to deploy the applications"
  type        = string
  default     = "prowlarr"
}

variable "username" {
  description = "Username for servarr applications."
  type        = string
  default     = "abc"
}

variable "password" {
  description = "Password for servarr applications."
  type        = string
  default     = "1"
}

variable "movies" {
  description = "The path to the directory containing Movies"
  type        = string
  default     = "/home/user/Downloads/Movies/Movies"
}

variable "shows" {
  description = "The path to the directory containing Shows"
  type        = string
  default     = "/home/user/Downloads/Movies/Shows"
}


