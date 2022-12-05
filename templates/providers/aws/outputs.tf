output "cert-manager" {
  value = var.modules.cert-manager.enabled ? module.cert-manager[0] : {}
}

output "velero" {
  value = var.modules.velero.enabled ? module.velero[0] : {}
}
