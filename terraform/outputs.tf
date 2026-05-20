output "container_name" {
  description = "Nom du container K3s server"
  value       = module.k3s_node.container_name
}

output "container_ip" {
  description = "IP du container sur le réseau interne"
  value       = module.k3s_node.container_ip
}

output "network_name" {
  description = "Nom du réseau Docker"
  value       = module.network.network_name
}
