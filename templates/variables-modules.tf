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
      enabled        = bool
      domain_filters = list(string)
      private        = bool
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
        externalUrl = string
      })
      grafana = object({
        externalUrl   = string
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
      enabled        = false
      domain_filters = []
      private        = false
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
        externalUrl = "https://prometheus.example.com"
      }
      grafana = {
        externalUrl   = "https://grafana.example.com"
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
  modules = {
    cert-manager = {
      enabled                   = try(var.modules.cert-manager.enabled, var.modules_defaults.cert-manager.enabled)
      cluster_oidc_issuer_url   = try(var.modules.cert-manager.cluster_oidc_issuer_url, var.modules_defaults.cert-manager.cluster_oidc_issuer_url)
      service_account_namespace = try(var.modules.cert-manager.service_account_namespace, var.modules_defaults.cert-manager.service_account_namespace)
      service_account_name      = try(var.modules.cert-manager.service_account_name, var.modules_defaults.cert-manager.service_account_name)
      tags                      = try(var.modules.cert-manager.tags, var.modules_defaults.cert-manager.tags)
      hosted_zone_ids           = try(var.modules.cert-manager.hosted_zone_ids, var.modules_defaults.cert-manager.hosted_zone_ids)
    }
    cert-manager-config = {
      enabled       = try(var.modules.cert-manager-config.enabled, var.modules_defaults.cert-manager-config.enabled)
      acme_email    = try(var.modules.cert-manager-config.acme_email, var.modules_defaults.cert-manager-config.acme_email)
      ingress_class = try(var.modules.cert-manager-config.ingress_class, var.modules_defaults.cert-manager-config.ingress_class)
    }
    external-dns = {
      enabled        = try(var.modules.external-dns.enabled, var.modules_defaults.external-dns.enabled)
      domain_filters = try(var.modules.external-domain_filters, var.modules_defaults.external-dns.domain_filters)
      private        = try(var.modules.external-private, var.modules_defaults.external-dns.private)
    }
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
      linkerd-jaeger = {
        enabled = try(var.modules.linkerd.linkerd-jaeger.enabled, var.modules_defaults.linkerd.linkerd-jaeger.enabled)
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
    monitoring = {
      enabled = try(var.modules.monitoring.enabled, var.modules_defaults.monitoring.enabled)
      prometheus = {
        externalUrl = try(var.modules.monitoring.prometheus.externalUrl, var.modules_defaults.monitoring.prometheus.externalUrl)
      }
      grafana = {
        externalUrl   = try(var.modules.monitoring.grafana.externalUrl, var.modules_defaults.monitoring.grafana.externalUrl)
        adminUsername = try(var.modules.monitoring.grafana.adminUsername, var.modules_defaults.monitoring.grafana.adminUsername)
        adminPassword = try(var.modules.monitoring.grafana.adminPassword, var.modules_defaults.monitoring.grafana.adminPassword)
      }
    }
    podinfo = {
      enabled  = try(var.modules.podinfo.enabled, var.modules_defaults.podinfo.enabled)
      hostname = try(var.modules.podinfo.hostname, var.modules_defaults.podinfo.hostname)
    }
    trivy = {
      enabled = try(var.modules.trivy.enabled, var.modules_defaults.trivy.enabled)
    }
    velero = {
      enabled                   = try(var.modules.velero.enabled, var.modules_defaults.velero.enabled)
      cluster_oidc_issuer_url   = try(var.modules.velero.cluster_oidc_issuer_url, var.modules_defaults.velero.cluster_oidc_issuer_url)
      service_account_namespace = try(var.modules.velero.service_account_namespace, var.modules_defaults.velero.service_account_namespace)
      service_account_name      = try(var.modules.velero.service_account_name, var.modules_defaults.velero.service_account_name)
      tags                      = try(var.modules.velero.tags, var.modules_defaults.velero.tags)
      bucket_name               = try(var.modules.velero.bucket_name, var.modules_defaults.velero.bucket_name)
    }
    weave-gitops = {
      enabled        = try(var.modules.weave-gitops.enabled, var.modules_defaults.weave-gitops.enabled)
      admin-username = try(var.modules.weave-gitops.admin-username, var.modules_defaults.weave-gitops.admin-username)
      admin-password = try(var.modules.weave-gitops.admin-password, var.modules_defaults.weave-gitops.admin-password)
    }
  }

  register_modules = {
    linkerd : local.modules.linkerd.enabled ? module.linkerd[0] : tomap({})
    weave-gitops : local.modules.weave-gitops.enabled ? local.weave-gitops : tomap({})
  }
}
