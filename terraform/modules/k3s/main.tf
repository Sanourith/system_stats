terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "this" {
  name         = var.node_image
  keep_locally = true
}

resource "docker_container" "this" {
  name  = "${var.project_name}-k3s"
  image = docker_image.this.image_id

  networks_advanced {
    name = var.network_name
  }

  privileged = true
  restart    = "unless-stopped"
  command    = ["/bin/bash", "-c", "while true; do sleep 3600; done"]
}
