module "provider-modules" {
  source = "./aws"

  modules       = local.modules
  cluster_name  = var.cluster_name
  customer_name = var.customer_name
}
