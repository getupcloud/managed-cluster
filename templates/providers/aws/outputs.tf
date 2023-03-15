output "cert-manager" {
  value = try(var.modules.cert-manager.enabled, false) ? module.cert-manager[0] : {}
}

output "velero" {
  value = try(var.modules.velero.enabled, false) ? module.velero[0] : {}
}

output "ebs-csi" {
  value = try(var.modules.ebs-csi.enabled, false) ? module.ebs-csi[0] : {}
}
