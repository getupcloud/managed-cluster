resource "kubernetes_config_map_v1" "cluster-monitoring-config" {
  count = var.cluster_monitoring_config.enabled ? 1 : 0

  metadata {
    name      = "cluster-monitoring-config"
    namespace = "openshift-monitoring"
  }

  data = {
    "config.yaml" = <<-EOT
      %{~if var.cluster_monitoring_config.enabled}
      enableUserWorkload: ${var.cluster_monitoring_config.enable_user_workload}
      prometheusK8s:
        resources:
          requests:
            cpu: ${var.cluster_monitoring_config.prometheus_k8s_requests_cpu}
            memory: ${var.cluster_monitoring_config.prometheus_k8s_requests_mem}
          limits:
            cpu: ${var.cluster_monitoring_config.prometheus_k8s_limits_cpu}
            memory: ${var.cluster_monitoring_config.prometheus_k8s_limits_mem}
          retention: ${var.cluster_monitoring_config.prometheus_k8s_retention}
          retentionSize: ${var.cluster_monitoring_config.prometheus_k8s_retention_size}
        logLevel: ${var.cluster_monitoring_config.prometheus_k8s_log_level}
      %{~endif}
    EOT
  }
}

resource "kubernetes_config_map_v1" "user-workload-monitoring-config" {
  count = var.user_workload_monitoring_config.enabled ? 1 : 0

  metadata {
    name      = "user-workload-monitoring-config"
    namespace = "openshift-user-workload-monitoring"
  }

  data = {
    "config.yaml" = <<-EOT
      %{~if var.user_workload_monitoring_config.enabled}
      prometheus:
        retention: ${var.user_workload_monitoring_config.enabled}
        retentionSize: ${var.user_workload_monitoring_config.prometheus_retention_size}
      alertmanager:
        enabled: ${var.user_workload_monitoring_config.alertmanager_enabled}
        enableAlertmanagerConfig: ${var.user_workload_monitoring_config.alertmanager_enable_alertmanager_config}
        logLevel: ${var.user_workload_monitoring_config.alertmanager_log_level}
      %{~endif}
    EOT
  }
}
