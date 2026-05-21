output "container_name" {
  value = docker_container.postgres.name
}

output "postgres_host" {
  description = "Hostname interne Docker — utilisé par l'app pour se connecter"
  value       = docker_container.postgres.name
}

output "postgres_port_internal" {
  value = 5432
}
