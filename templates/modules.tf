# Must register all modules in locals.tf

module "linkerd" {
  count  = try(local.modules.linkerd.enabled, false) ? 1 : 0
  source = "github.com/getupcloud/terraform-module-linkerd?ref=v0.6"
}

locals {
  weave-gitops = {
    admin-username = local.modules.weave-gitops.enabled ? local.modules.weave-gitops.admin-username : ""
    admin-password = local.modules.weave-gitops.enabled ? local.modules.weave-gitops.admin-password : ""
    admin-password-hash = bcrypt(local.modules.weave-gitops.enabled ? local.modules.weave-gitops.admin-password : "")
  }
}
