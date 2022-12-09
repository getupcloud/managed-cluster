locals {
  kubeconfig_filename = abspath(pathexpand(var.kubeconfig_filename))

  modules_result = {
    for name, config in local.modules : name => merge(config,
      { output : config.enabled ? lookup(local.register_modules, name, tomap({})) : tomap({}) }
    )
  }

  manifests_template_vars = merge({
    cluster_name : var.cluster_name
    cluster_sla : var.cluster_sla
    cluster_type : local.cluster_type
    customer_name : var.customer_name
    modules : local.modules_result
    }, var.manifests_template_vars
  )
}
