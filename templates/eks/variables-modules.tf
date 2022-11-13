## Provider-specific modules variables
## Copy to toplevel

variable "modules_defaults_provider" {
  description = "Configure AWS modules to install (defaults)"
  type = object({
    alb = object({
      enabled      = bool
      ingressClass = string
    })
    cert-manager = object({
      enabled         = bool
      hosted_zone_ids = list(string)
    })
    cluster-autoscaler = object({ enabled = bool })
    ebs_csi            = object({ enabled = bool })
    ecr                = object({ enabled = bool })
    efs = object({
      enabled        = bool
      file_system_id = string
    })
    external-dns = object({
      enabled         = bool
      hosted_zone_ids = list(string)
    })
    kms = object({
      enabled = bool
      key_id  = string
    })
    loki   = object({ enabled = bool })
    thanos = object({ enabled = bool })
    velero = object({
      enabled     = bool
      bucket_name = string
    })
  })

  default = {
    alb = {
      enabled      = true
      ingressClass = "alb"
    }
    cert-manager = {
      enabled         = false
      hosted_zone_ids = []
    }
    cluster-autoscaler = {
      enabled = true
    }
    ebs_csi = {
      enabled = true
    }
    ecr = {
      enabled = false
    }
    efs = {
      enabled        = false
      file_system_id = ""
    }
    external-dns = {
      enabled         = false
      hosted_zone_ids = []
    }
    kms = {
      enabled = false
      key_id  = ""
    }
    loki = {
      enabled = true
    }
    thanos = {
      enabled = false
    }
    velero = {
      enabled     = true
      bucket_name = ""
    }
  }
}
