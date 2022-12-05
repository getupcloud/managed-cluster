module "cert-manager" {
  count  = var.modules.cert-manager.enabled ? 1 : 0
  source = "github.com/getupcloud/terraform-module-aws-cert-manager?ref=v1.1.0"

  cluster_name  = var.cluster_name
  customer_name = var.customer_name

  cluster_oidc_issuer_url   = local.modules.cert-manager.cluster_oidc_issuer_url
  service_account_namespace = local.modules.cert-manager.service_account_namespace
  service_account_name      = local.modules.cert-manager.service_account_name
  tags                      = local.modules.cert-manager.tags
  hosted_zone_ids           = local.modules.cert-manager.hosted_zone_ids
}

module "velero" {
  count  = var.modules.velero.enabled ? 1 : 0
  source = "github.com/getupcloud/terraform-module-aws-velero?ref=v1.8.1"

  cluster_name  = var.cluster_name
  customer_name = var.customer_name

  cluster_oidc_issuer_url   = local.modules.velero.cluster_oidc_issuer_url
  service_account_namespace = local.modules.velero.service_account_namespace
  service_account_name      = local.modules.velero.service_account_name
  tags                      = local.modules.velero.tags
  bucket_name               = local.modules.velero.bucket_name
}
