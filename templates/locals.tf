locals {
  manifests_template_vars = merge({
    cluster_name : var.name
    cluster_sla : var.sla
    customer_name : var.customer
  }, var.manifests_template_vars)
}
