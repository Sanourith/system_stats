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
  description = "Image Docker pour le nœud K3s"
  type        = string
  default     = "ubuntu:22.04"
}

variable "network_subnet" {
  type    = string
  default = "172.20.0.0/16"
}

variable "network_gateway" {
  type    = string
  default = "172.20.0.1"
}

variable "postgres_image" {
  description = "Image PostgreSQL sur ton DockerHub"
  type        = string
}

variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "postgres_db" {
  type    = string
  default = "infrawatch"
}

variable "postgres_user" {
  type    = string
  default = "infrawatch"
}

variable "app_image" {
  description = "Image de l'app Python sur ton DockerHub"
  type        = string
}
