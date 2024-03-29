locals {
  kubeconfig_filename = var.kubeconfig_filename != "" ? abspath(pathexpand(var.kubeconfig_filename)) : ""

  modules_result = {
    for name, config in merge(var.modules, local.modules) : name => merge(config,
      { output : config.enabled ? lookup(merge(local.register_modules, module.provider-modules), name, tomap({})) : tomap({}) }
    )
  }

  manifests_template_vars = merge({
    cluster_name : var.cluster_name
    cluster_sla : var.cluster_sla
    cluster_type : local.cluster_type
    customer_name : var.customer_name
    kubernetes_version : var.kubernetes_version
    modules : local.modules_result
    }, var.manifests_template_vars
  )
}
