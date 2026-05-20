output "container_name" {
  value = docker_container.this.name
}

output "container_ip" {
  value = docker_container.this.network_data[0].ip_address
}
