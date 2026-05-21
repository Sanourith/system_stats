module "network" {
  source = "./modules/network"

  providers = {
    docker = docker  # <- propagation explicite
  }

  project_name    = var.project_name
  network_subnet  = var.network_subnet
  network_gateway = var.network_gateway
}

module "k3s" {
  source = "./modules/k3s"

  providers = {
    docker = docker  # <- propagation explicite
  }

  project_name = var.project_name
  node_image   = var.node_image
  network_name = module.network.network_name
}

module "postgres" {
  source    = "./modules/postgres"
  providers = { docker = docker }

  project_name      = var.project_name
  network_name      = module.network.network_name
  postgres_image    = var.postgres_image
  postgres_password = var.postgres_password
  postgres_db       = var.postgres_db
  postgres_user     = var.postgres_user
}

module "app" {
  source    = "./modules/app"
  providers = { docker = docker }

  project_name      = var.project_name
  network_name      = module.network.network_name
  app_image         = var.app_image
  postgres_host     = module.postgres.postgres_host
  postgres_db       = var.postgres_db
  postgres_user     = var.postgres_user
  postgres_password = var.postgres_password
}

module "prometheus" {
  source    = "./modules/prometheus"
  providers = { docker = docker }

  project_name       = var.project_name
  network_name       = module.network.network_name
  app_container_name = module.app.container_name
}
