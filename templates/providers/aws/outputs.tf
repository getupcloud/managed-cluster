output "cert-manager" {
  value = var.modules.cert-manager.enabled ? module.cert-manager[0] : {}
}

output "velero" {
  value = var.modules.velero.enabled ? module.velero[0] : {}
}

output "ebs-csi" {
  value = var.modules.ebs-csi.enabled ? module.ebs-csi[0] : {}
}
