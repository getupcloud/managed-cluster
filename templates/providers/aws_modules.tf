module "provider-modules" {
  source  = "./aws"

  modules = var.modules
  cluster_name  = var.cluster_name
  customer_name = var.customer_name
}
