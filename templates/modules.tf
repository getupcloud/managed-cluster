# Must register all modules in locals.tf

module "linkerd" {
  count  = try(local.modules.linkerd.enabled, false) ? 1 : 0
  source = "github.com/getupcloud/terraform-module-linkerd?ref=v0.6"
}
