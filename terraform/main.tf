module "network" {
  source = "./modules/network"

  providers = {
    docker = docker  # <- propagation explicite
  }

  project_name    = var.project_name
  network_subnet  = var.network_subnet
  network_gateway = var.network_gateway
}

module "k3s_node" {
  source = "./modules/k3s"

  providers = {
    docker = docker  # <- propagation explicite
  }

  project_name = var.project_name
  node_image   = var.node_image
  network_name = module.network.network_name
}
