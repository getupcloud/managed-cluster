variable "modules_defaults" {
  description = "Configure modules to install (defaults)"
  type = object({
    cert-manager = object({
      enabled                   = bool
      cluster_oidc_issuer_url   = string
      service_account_namespace = string
      service_account_name      = string
      tags                      = map(string)
      hosted_zone_ids           = list(string)
    })
    cert-manager-config = object({
      enabled       = bool
      acme_email    = string
      ingress_class = string
    })
    external-dns = object({
      enabled         = bool
      domain_filters  = list(string)
      hosted_zone_ids = list(string)
      private         = bool
    })
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
      enabled        = bool
      linkerd-cni    = object({ enabled = bool })
      linkerd-jaeger = object({ enabled = bool })
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
    monitoring = object({
      enabled = bool
      prometheus = object({
        ingress = object({
          enabled = bool
          scheme  = string
          host    = string
          className = string
          clusterIssuer = string
        })
      })
      grafana = object({
        ingress = object({
          enabled = bool
          scheme  = string
          host    = string
          className = string
          clusterIssuer = string
        })
        adminUsername = string
        adminPassword = string
      })
    })
    podinfo = object({
      enabled  = bool
      hostname = string
    })
    trivy = object({ enabled = bool })
    velero = object({
      enabled                   = bool
      cluster_oidc_issuer_url   = string
      service_account_namespace = string
      service_account_name      = string
      tags                      = map(string)
      bucket_name               = string
    })
    weave-gitops = object({
      enabled        = bool
      admin-username = string
      admin-password = string
    })
  })

  default = {
    cert-manager = {
      enabled                   = false
      cluster_oidc_issuer_url   = ""
      service_account_namespace = "cert-manager"
      service_account_name      = "cert-manger"
      tags                      = {}
      hosted_zone_ids           = []
    }
    cert-manager-config = {
      enabled       = false
      acme_email    = "change.me@example.com"
      ingress_class = "nginx"
    }
    external-dns = {
      enabled         = false
      domain_filters  = []
      hosted_zone_ids = []
      private         = false
    }
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
      linkerd-jaeger = {
        enabled = true
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
    monitoring = {
      enabled = true
      prometheus = {
        ingress = {
          enabled = false
          scheme  = "https"
          host    = "prometheus.example.com"
          className = "nginx"
          clusterIssuer = ""
        }
      }
      grafana = {
        ingress = {
          enabled = false
          scheme  = "https"
          host    = "grafana.example.com"
          className = "nginx"
          clusterIssuer = ""
        }
        adminUsername = "admin"
        adminPassword = "prom-operator"
      }
    }
    podinfo = {
      enabled  = false
      hostname = "podinfo.example.com"
    }
    trivy = {
      enabled = false
    }
    velero = {
      enabled                   = false
      cluster_oidc_issuer_url   = ""
      service_account_namespace = "velero"
      service_account_name      = "velero"
      tags                      = {}
      bucket_name               = ""
    }
    weave-gitops = {
      enabled        = false
      admin-username = "admin"
      admin-password = "admin"
    }
  }
}

locals {
  register_modules = {
    linkerd : local.modules.linkerd.enabled ? module.linkerd[0] : tomap({})
    weave-gitops : local.modules.weave-gitops.enabled ? local.weave-gitops : tomap({})
  }
}
