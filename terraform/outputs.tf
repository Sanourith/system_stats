output "network_name" {
  description = "Nom du réseau Docker"
  value       = module.network.network_name
}

output "k3s_container_name" {
  description = "Nom du container K3s"
  value       = module.k3s.container_name
}

output "k3s_container_ip" {
  description = "IP du container K3s"
  value       = module.k3s.container_ip
}

output "postgres_host" {
  description = "Hostname PostgreSQL (interne Docker)"
  value       = module.postgres.postgres_host
}

output "app_container_name" {
  description = "Nom du container app Python"
  value       = module.app.container_name
}

output "app_metrics_url" {
  description = "URL des métriques Prometheus"
  value       = module.app.metrics_url
}

output "prometheus_url" {
  description = "URL Prometheus"
  value       = module.prometheus.prometheus_url
}
