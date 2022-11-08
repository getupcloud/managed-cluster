locals {
  modules = merge(var.modules_defaults, var.modules)

  manifests_template_vars = merge({
    cluster_name : var.name
    cluster_sla : var.sla
    cluster_type : local.cluster_type
    customer_name : var.customer
  }, var.manifests_template_vars)

  cronitor_notification_list = var.cronitor_notification_lists[var.sla]
}
