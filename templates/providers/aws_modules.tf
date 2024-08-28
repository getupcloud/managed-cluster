variable "account_id" {
  description = "AWS account ID"
  type        = string
  default     = ""
}

module "provider-modules" {
  source = "./aws"

  modules       = merge(var.modules, local.modules)
  cluster_name  = var.cluster_name
  customer_name = var.customer_name
  account_id    = var.account_id
}
