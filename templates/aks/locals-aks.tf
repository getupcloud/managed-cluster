locals {
  cluster_type   = "aks"
  dns_service_ip = (var.service_cidr != null && var.dns_service_ip == null) ? cidrhost(var.service_cidr, 3) : var.dns_service_ip
}
