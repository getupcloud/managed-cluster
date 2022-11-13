locals {
  modules = merge(var.modules_defaults, var.modules)

  register_modules = {
    linkerd : local.modules.linkerd.enabled ? module.linkerd[0] : tomap({})
  }

  modules_result = {
    for name, config in local.modules : name => merge(config, {
      output : config.enabled ? lookup(local.register_modules, name, {}) : tomap({})
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
