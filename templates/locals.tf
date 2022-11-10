locals {
  modules = merge(var.modules_defaults, var.modules_defaults_provider, var.modules)

  manifests_template_vars = merge({
    cluster_name : var.cluster_name
    cluster_sla : var.cluster_sla
    cluster_type : local.cluster_type
    customer_name : var.customer_name
  }, var.manifests_template_vars)
}
