resource "kubernetes_config_map_v1" "cluster-monitoring-config" {
  metadata {
    name      = "cluster-monitoring-config"
    namespace = "openshift-monitoring"
  }

  data = {
    "config.yaml" = <<-EOT
      enableUserWorkload: true
      prometheusK8s:
        resources:
          requests:
            memory: 4Gi
            cpu: 1
          limits:
            memory: 12Gi
            cpu: 2
          retention: 30d
          retentionSize: 50GiB
        logLevel: info
    EOT
  }
}

resource "kubernetes_config_map_v1" "user-workload-monitoring-config" {
  metadata {
    name      = "user-workload-monitoring-config"
    namespace = "openshift-user-workload-monitoring"
  }

  data = {
    "config.yaml" = <<-EOT
      prometheus:
        retention: 24h
        retentionSize: 10GiB
      alertmanager:
        enabled: true
        enableAlertmanagerConfig: true
        logLevel: info
    EOT
  }
}
