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
      })
      emojivoto = object({ enabled = bool })
    })
    podinfo = object({ enabled = bool })
    trivy   = object({ enabled = bool })
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
        username = "linkerd"
        password = "linkerd-admin"
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
      admin-password = "weave-admin"
    }
  }
}
