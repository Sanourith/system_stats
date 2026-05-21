terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "local_file" "prometheus_config" {
  content = templatefile("${path.module}/config/prometheus.yml", {
    app_container_name = var.app_container_name
  })
  filename = "${path.module}/config/prometheus_rendered.yml"
}

resource "docker_image" "prometheus" {
  name         = "prom/prometheus:latest"
  keep_locally = true
}

resource "docker_container" "prometheus" {
  name  = "${var.project_name}-prometheus"
  image = docker_image.prometheus.image_id

  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = 9090
    external = var.prometheus_port
  }

  volumes {
    host_path      = abspath("${path.module}/config/prometheus_rendered.yml")
    container_path = "/etc/prometheus/prometheus.yml"
    read_only      = true
  }

  restart    = "unless-stopped"
  depends_on = [local_file.prometheus_config]
}
