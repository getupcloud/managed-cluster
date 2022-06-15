locals {
  generic_modules = merge(var.okd_modules_defaults, var.okd_modules)
}
