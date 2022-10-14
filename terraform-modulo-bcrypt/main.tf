resource "random_password" "this" {
  keepers          = var.keepers
  length           = var.length
  lower            = var.lower
  min_lower        = var.min_lower
  min_numeric      = var.min_numeric
  min_special      = var.min_special
  min_upper        = var.min_upper
  numeric          = var.number
  upper            = var.upper
  special          = var.special
}
