variable "modules_defaults" {
  description = "Configure modules to install (defaults)"
  type = object({
    linkerd             = object({ enabled = bool })
    linkerd-cni         = object({ enabled = bool })
    linkerd-viz         = object({ enabled = bool })
    trivy               = object({ enabled = bool })
    kube_opex_analytics = object({ enabled = bool })
  })

  default = {
    linkerd = {
      enabled = false
    }
    linkerd-cni = {
      enabled = false
    }
    linkerd-viz = {
      enabled = false
    }
    trivy = {
      enabled = false
    }
    kube_opex_analytics = {
      enabled = false
    }
  }
}


