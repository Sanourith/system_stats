output "container_name" {
  value = docker_container.prometheus.name
}

output "prometheus_url" {
  value = "http://localhost:${var.prometheus_port}"
}
