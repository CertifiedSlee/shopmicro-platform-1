terraform {
  required_version = ">= 1.6.0"
}
module "network" {
  source = "../modules/network"
  name   = "shopmicro-dev"
}
output "vpc_id" { value = module.network.vpc_id }
