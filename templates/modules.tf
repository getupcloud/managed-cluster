# Must register all modules in locals.tf

module "linkerd" {
  count  = try(local.modules.linkerd.enabled, false) ? 1 : 0
  source = "github.com/getupcloud/terraform-module-linkerd?ref=v0.6"
}

module "weave-gitops-password" {
  count  = try(local.modules.weave-gitops.enabled, false) ? 1 : 0
  source = "github.com/getupcloud/terraform-module-password?ref=v0.1.0"

  algorithm  = "bcrypt"
  plain_text = local.modules.weave-gitops.admin-password
}

locals {
  weave-gitops = {
    admin-username = local.modules.weave-gitops.enabled ? local.modules.weave-gitops.admin-username : ""
    admin-password-hash = local.modules.weave-gitops.enabled ? module.weave-gitops-password[0].secret : ""
  }
}
