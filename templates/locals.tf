locals {
  modules = merge(var.modules_defaults, var.modules_defaults_provider, var.modules)

  modules_result = {
    for name, module in local.modules : name => merge(module[0], {
      output : lookup(var.modules, name).enabled ? module[0] : tomap({})
    })
  }

  manifests_template_vars = merge(
    {
      cluster_name : var.cluster_name
      cluster_sla : var.cluster_sla
      cluster_type : local.cluster_type
      customer_name : var.customer_name
      modules : local.modules_result
    },
    var.manifests_template_vars)
}
