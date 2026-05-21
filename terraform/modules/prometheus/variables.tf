variable "project_name" {
  type = string
}

variable "network_name" {
  type = string
}

variable "app_container_name" {
  description = "Nom du container app, pour configurer le scraping"
  type        = string
}

variable "prometheus_port" {
  type    = number
  default = 9090
}
