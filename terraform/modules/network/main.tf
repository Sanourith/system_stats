terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_network" "this" {
  name   = "${var.project_name}-network"
  driver = "bridge"

  ipam_config {
    subnet  = var.network_subnet
    gateway = var.network_gateway
  }
}
