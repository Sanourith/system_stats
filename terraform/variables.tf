variable "docker_host" {
  description = "Socket Docker local"
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "project_name" {
  description = "Préfixe pour nommer toutes les ressources"
  type        = string
  default     = "infrawatch"
}

variable "node_image" {
  description = "Image Docker utilisée pour les nœuds"
  type        = string
  default     = "ubuntu:22.04"
}

variable "network_subnet" {
  description = "Subnet du réseau Docker interne"
  type        = string
  default     = "172.20.0.0/16"
}

variable "network_gateway" {
  description = "Gateway du réseau Docker interne"
  type        = string
  default     = "172.20.0.1"
}
