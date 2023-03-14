## TODO

module "provider-modules" {
  source = "./oci"

  #modules = merge(var.modules, local.modules)
  #cluster_name  = var.cluster_name
  #customer_name = var.customer_name
}
