module "cert-manager" {
  count  = var.modules.cert-manager.enabled ? 1 : 0
  source = "github.com/getupcloud/terraform-module-aws-cert-manager?ref=v1.1.2"

  cluster_name  = var.cluster_name
  customer_name = var.customer_name

  cluster_oidc_issuer_url   = var.modules.cert-manager.cluster_oidc_issuer_url
  service_account_namespace = var.modules.cert-manager.service_account_namespace
  service_account_name      = var.modules.cert-manager.service_account_name
  tags                      = var.modules.cert-manager.tags
  hosted_zone_ids           = var.modules.cert-manager.hosted_zone_ids
}

module "velero" {
  count  = var.modules.velero.enabled ? 1 : 0
  source = "github.com/getupcloud/terraform-module-aws-velero?ref=v1.8.2"

  cluster_name  = var.cluster_name
  customer_name = var.customer_name

  cluster_oidc_issuer_url   = var.modules.velero.cluster_oidc_issuer_url
  service_account_namespace = var.modules.velero.service_account_namespace
  service_account_name      = var.modules.velero.service_account_name
  tags                      = var.modules.velero.tags
  bucket_name               = var.modules.velero.bucket_name
}

module "ebs-csi" {
  count  = var.modules.ebs-csi.enabled ? 1 : 0
  source = "github.com/getupcloud/terraform-module-aws-ebs-csi?ref=v0.1"

  cluster_name            = var.cluster_name
  cluster_oidc_issuer_url = var.modules.velero.cluster_oidc_issuer_url
}
