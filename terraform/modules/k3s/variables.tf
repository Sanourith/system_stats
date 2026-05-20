variable "project_name" {
  type = string
}

variable "node_image" {
  type    = string
  default = "ubuntu:22.04"
}

variable "network_name" {
  description = "Nom du réseau Docker auquel rattacher le container"
  type        = string
}
