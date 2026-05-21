variable "project_name" {
  type = string
}

variable "network_name" {
  type = string
}

variable "app_image" {
  type = string
}

variable "app_port" {
  type    = number
  default = 8000
}

variable "postgres_host" {
  type = string
}

variable "postgres_db" {
  type = string
}

variable "postgres_user" {
  type = string
}

variable "postgres_password" {
  type      = string
  sensitive = true
}
