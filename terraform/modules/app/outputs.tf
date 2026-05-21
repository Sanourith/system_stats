output "container_name" {
  value = docker_container.app.name
}

output "metrics_url" {
  value = "http://localhost:${var.app_port}/metrics"
}
