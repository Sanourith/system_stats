variable "project_name" {
  type = string
}

variable "network_subnet" {
  type    = string
  default = "172.20.0.0/16"
}

variable "network_gateway" {
  type    = string
  default = "172.20.0.1"
}
