variable "project_name" {
  type = string
}

variable "network_name" {
  type = string
}

variable "postgres_image" {
  description = "Image PostgreSQL (DockerHub perso ou officielle)"
  type        = string
  default     = "postgres:16"
}

variable "postgres_db" {
  type    = string
  default = "infrawatch"
}

variable "postgres_user" {
  type    = string
  default = "infrawatch"
}

variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "postgres_port" {
  type    = number
  default = 5432
}
