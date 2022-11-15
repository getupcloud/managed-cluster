# Must register all modules in locals.tf

module "linkerd" {
  count  = local.modules.linkerd.enabled ? 1 : 0
  source = "github.com/getupcloud/terraform-module-linkerd?ref=v0.6"
}

module "weave-gitops-password" {
  count  = local.modules.weave-gitops.enabled ? 1 : 0
  source = "github.com/getupcloud/terraform-module-password?ref=v0.1.0"

  algorithm  = "bcrypt"
  plain_text = local.modules.weave-gitops.admin-password
}

locals {
  weave-gitops = {
    admin-password-hash = local.modules.weave-gitops.enabled ? module.weave-gitops-password[0].secret : ""
  }
}

resource "local_file" "debug-modules" {
  count = var.dump_debug ? 1 : 0
  filename = ".debug-modules.json"
  content = data.merge_merge.modules.output
}
