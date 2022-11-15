variable "modules_defaults" {
  description = "Configure modules to install (defaults)"
  type = object({
    falco = object({
      enabled         = bool
      event-generator = object({ enabled = bool })
      falco-exporter  = object({ enabled = bool })
    })
    kube_opex_analytics = object({ enabled = bool })
    kyverno = object({
      enabled          = bool
      kyverno-policies = object({ enabled = bool })
    })
    linkerd = object({
      enabled     = bool
      linkerd-cni = object({ enabled = bool })
      linkerd-viz = object({ enabled = bool })
    })
    trivy = object({ enabled = bool })
  })

  default = {
    falco = {
      enabled = false
      event-generator = {
        enabled = true
      }
      falco-exporter = {
        enabled = false
      }
    }
    kube_opex_analytics = {
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
        enabled = false
      }
    }
    trivy = {
      enabled = false
    }
    weave-gitops = {
      enabled = false
      admin-username = "admin"
      admin-password = "weave-admin"
    }
  }
}
