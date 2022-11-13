## Provider-specific modules variables
## Copy to toplevel

variable "modules_defaults_provider" {
  description = "Configure Azure modules to install (defaults)"
  type = object({
    cert-manager = object({
      enabled         = bool
      hosted_zone_ids = list(string)
    })
    loki   = object({ enabled = bool })
    velero = object({ enabled = bool })
  })

  default = {
    cert-manager = {
      enabled         = false
      hosted_zone_ids = []
    }
    loki = {
      enabled = true
    }
    velero = {
      enabled = true
    }
  }
}

