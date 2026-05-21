terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_image" "app" {
  name         = var.app_image
  keep_locally = true
}

resource "docker_container" "app" {
  name  = "${var.project_name}-app"
  image = docker_image.app.image_id

  networks_advanced {
    name = var.network_name
  }

  env = [
    "DB_HOST=${var.postgres_host}",
    "DB_PORT=5432",
    "DB_NAME=${var.postgres_db}",
    "DB_USER=${var.postgres_user}",
    "DB_PASSWORD=${var.postgres_password}",
    "METRICS_PORT=8000",
  ]

  ports {
    internal = 8000
    external = var.app_port
  }

  restart = "unless-stopped"
}
