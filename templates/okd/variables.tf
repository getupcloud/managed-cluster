variable "api_endpoint" {
  description = "Kubernetes API endpoint (Informative only)"
  type        = string
  default     = ""
}

variable "okd_modules" {
  description = "Configure OKD modules to install"
  type        = any
  default     = {}
}

variable "okd_modules_defaults" {
  description = "Configure OKD modules to install (defaults)"
  type = object({
    linkerd     = object({ enabled = bool })
    linkerd-cni = object({ enabled = bool })
  })

  default = {
    linkerd : {
      enabled : false
      nodeSelector : {
        role : "infra"
      }
    }
    linkerd-viz : {
      enabled : false
      nodeSelector : {
        role : "infra"
      }
    }
    linkerd-cni : {
      enabled : false
      nodeSelector : {
        role : "infra"
      }
    }
  }
}
