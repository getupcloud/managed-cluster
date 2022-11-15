data "merge_merge" "modules" {

  dynamic "input" {
    for_each = [var.modules_defaults, var.modules]

    content {
      format = "json"
      data   = jsonencode(input.value)
    }
  }
  output_format = "json"
}

locals {
  modules = jsondecode(data.merge_merge.modules.output)

  register_modules = {
    linkerd : local.modules.linkerd.enabled ? module.linkerd[0] : tomap({})
    weave-gitops : local.modules.weave-gitops.enabled ? local.weave-gitops : tomap({})
  }

  modules_result = {
    for name, config in local.modules : name => merge(config, {
      output : config.enabled ? lookup(local.register_modules, name, {}) : tomap({})
    })
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
