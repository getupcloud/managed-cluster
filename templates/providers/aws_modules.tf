module "provider-modules" {
  source = "./aws"

  modules       = merge(var.modules, local.modules)
  cluster_name  = var.cluster_name
  customer_name = var.customer_name
}
