variable "modules_defaults" {
  description = "Configure modules to install (defaults)"
  type = object({
    falco = object({
      enabled         = bool
      event-generator = object({ enabled = bool })
      falco-exporter  = object({ enabled = bool })
      node-setup      = object({ enabled = bool })
    })
    kube-opex-analytics = object({ enabled = bool })
    kong                = object({ enabled = bool })
    kyverno = object({
      enabled          = bool
      kyverno-policies = object({ enabled = bool })
    })
    linkerd = object({
      enabled     = bool
      linkerd-cni = object({ enabled = bool })
      linkerd-viz = object({
        enabled  = bool
        username = string
        password = string
        hostname = string
      })
      emojivoto = object({
        enabled  = bool
        hostname = string
      })
    })
    podinfo = object({
      enabled  = bool
      hostname = string
    })
    trivy = object({ enabled = bool })
    weave-gitops = object({
      enabled        = bool
      admin-username = string
      admin-password = string
    })
  })

  default = {
    falco = {
      enabled = false
      event-generator = {
        enabled = true
      }
      falco-exporter = {
        enabled = true
      }
      node-setup = {
        enabled = true
      }
    }
    kong = {
      enabled = false
    }
    kube-opex-analytics = {
      enabled = false
    }
    kyverno = {
      enabled = false
      kyverno-policies = {
        enabled = true
      }
    }
    linkerd = {
      enabled = false
      linkerd-cni = {
        enabled = false
      }
      linkerd-viz = {
        enabled  = true
        username = "admin"
        password = "admin"
        hostname = "linkerd-viz.example.com"
      }
      emojivoto = {
        enabled  = false
        hostname = "emojivoto.example.com"
      }
    }
    podinfo = {
      enabled  = false
      hostname = "podinfo.example.com"
    }
    trivy = {
      enabled = false
    }
    weave-gitops = {
      enabled        = false
      admin-username = "admin"
      admin-password = "admin"
    }
  }
}

locals {
  modules = merge(var.modules_defaults, var.modules, {
    falco = {
      enabled = try(var.modules.falco.enabled, var.modules_defaults.falco.enabled)
      event-generator = {
        enabled = try(var.modules.falco.event-generator.enabled, var.modules_defaults.falco.event-generator.enabled)
      }
      falco-exporter = {
        enabled = try(var.modules.falco.falco-exporter.enabled, var.modules_defaults.falco.falco-exporter.enabled)
      }
      node-setup = {
        enabled = try(var.modules.falco.node-setup.enabled, var.modules_defaults.falco.node-setup.enabled)
      }
    }
    kong = {
      enabled = try(var.modules.kong.enabled, var.modules_defaults.kong.enabled)
    }
    kube-opex-analytics = {
      enabled = try(var.modules.kube-opex-analytics.enabled, var.modules_defaults.kube-opex-analytics.enabled)
    }
    kyverno = {
      enabled = try(var.modules.kyverno.enabled, var.modules_defaults.kyverno.enabled)
      kyverno-policies = {
        enabled = try(var.modules.kyverno.kyverno-policies.enabled, var.modules_defaults.kyverno.kyverno-policies.enabled)
      }
    }
    linkerd = {
      enabled = try(var.modules.linkerd.enabled, var.modules_defaults.linkerd.enabled)
      linkerd-cni = {
        enabled = try(var.modules.linkerd.linkerd-cni.enabled, var.modules_defaults.linkerd.linkerd-cni.enabled)
      }
      linkerd-viz = {
        enabled  = try(var.modules.linkerd.linkerd-viz.enabled, var.modules_defaults.linkerd.linkerd-viz.enabled)
        username = try(var.modules.linkerd.linkerd-viz.username, var.modules_defaults.linkerd.linkerd-viz.username)
        password = try(var.modules.linkerd.linkerd-viz.password, var.modules_defaults.linkerd.linkerd-viz.password)
        hostname = try(var.modules.linkerd.linkerd-viz.hostname, var.modules_defaults.linkerd.linkerd-viz.hostname)
      }
      emojivoto = {
        enabled  = try(var.modules.linkerd.emojivoto.enabled, var.modules_defaults.linkerd.emojivoto.enabled)
        hostname = try(var.modules.linkerd.emojivoto.hostname, var.modules_defaults.linkerd.emojivoto.hostname)
      }
    }
    podinfo = {
      enabled  = try(var.modules.podinfo.enabled, var.modules_defaults.podinfo.enabled)
      hostname = try(var.modules.podinfo.hostname, var.modules_defaults.podinfo.hostname)
    }
    trivy = {
      enabled = try(var.modules.trivy.enabled, var.modules_defaults.trivy.enabled)
    }
    weave-gitops = {
      enabled        = try(var.modules.weave-gitops.enabled, var.modules_defaults.weave-gitops.enabled)
      admin-username = try(var.modules.weave-gitops.admin-username, var.modules_defaults.weave-gitops.admin-username)
      admin-password = try(var.modules.weave-gitops.admin-password, var.modules_defaults.weave-gitops.admin-password)
    }
  })

  register_modules = {
    linkerd : local.modules.linkerd.enabled ? module.linkerd[0] : tomap({})
    weave-gitops : local.modules.weave-gitops.enabled ? local.weave-gitops : tomap({})
  }
}
