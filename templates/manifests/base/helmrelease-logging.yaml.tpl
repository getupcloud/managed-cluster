%{ if modules.logging.enabled ~}
---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: loki
  namespace: flux-system
spec:
  chart:
    spec:
      chart: loki
      sourceRef:
        kind: HelmRepository
        name: grafana
      version: "~> 2.10"
  install:
    createNamespace: true
    disableWait: false
    remediation:
      retries: -1
  upgrade:
    disableWait: false
    remediation:
      retries: -1
  interval: 5m
  releaseName: loki
  storageNamespace: logging
  targetNamespace: logging
  values:
    config:
      auth_enabled: false
      ingester:
        chunk_encoding: lz4
        chunk_idle_period: 10m
        chunk_retain_period: 0s
        wal:
          flush_on_shutdown: true
      limits_config:
        max_entries_limit_per_query: 100000
      chunk_store_config:
        max_look_back_period: 720h
      table_manager:
        retention_deletes_enabled: true
        retention_period: 720h
      ruler:
        storage:
          type: local
          local:
            directory: /rules
        rule_path: /tmp/scratch
        alertmanager_url: http://monitoring-kube-prometheus-alertmanager.svc.monitoring:9093
        ring:
          kvstore:
            store: inmemory
        enable_api: true

    alerting_groups:
    - name: Missing Log Lines for 30m
      rules:
      - alert: NoLogLinesForTooLong
        expr: sum(count_over_time({namespace="logging"}[30s])) == 0
        for: 30m

    ingress:
      enabled: false

    tolerations:
    - key: dedicated
      value: infra
      effect: NoSchedule

    affinity:
      nodeAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          preference:
            matchExpressions:
            - key: node-role.kubernetes.io/infra
              operator: Exists
        - weight: 100
          preference:
            matchExpressions:
            - key: role
              operator: In
              values:
              - infra

    resources:
      limits:
        cpu: 1
        memory: 4Gi
      requests:
        cpu: 100m
        memory: 1Gi

    #priorityClassName: high-priority

    persistence:
      enabled: true
      # storageClassName: gp2
      size: 500Gi

    serviceMonitor:
      enabled: true
      interval: 60s

    rbac:
      pspEnabled: false
---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: promtail
  namespace: flux-system
spec:
  chart:
    spec:
      chart: promtail
      sourceRef:
        kind: HelmRepository
        name: grafana
      version: "~> 3.11"
  dependsOn:
  - name: loki
  install:
    createNamespace: true
    disableWait: false
    remediation:
      retries: -1
  upgrade:
    disableWait: false
    remediation:
      retries: -1
  interval: 5m
  releaseName: promtail
  storageNamespace: logging
  targetNamespace: logging
  values:
    config:
      lokiAddress: http://loki:3100/loki/api/v1/push

      snippets:
        extraRelabelConfigs:
        # keep all kubernetes labels
        - action: labelmap
          regex: __meta_kubernetes_pod_label_(.+)
        # remove hashing labels in order to decrease cardinality
        - action: labeldrop
          regex: __meta_kubernetes_pod_label_.*_hash

    tolerations:
    - key: dedicated
      value: infra
      effect: NoSchedule

    resources:
      limits:
        cpu: 1
        memory: 2Gi
      requests:
        cpu: 100m
        memory: 64Mi

    updateStrategy:
      type: RollingUpdate
      rollingUpdate:
        maxUnavailable: "20%"

    serviceMonitor:
      enabled: true
      interval: 60s

    volumes:
    - name: containers
      hostPath:
        path: /var/lib/containers
    - name: docker
      hostPath:
        path: /var/lib/docker/containers
    - name: pods
      hostPath:
        path: /var/log/pods
    #
    # OCI OKE
    #
    #- hostPath:
    #    path: /u01
    #  name: u01

    volumeMounts:
    - name: containers
      mountPath: /var/lib/containers
      readOnly: true
    - name: docker
      mountPath: /var/lib/docker/containers
      readOnly: true
    - name: pods
      mountPath: /var/log/pods
      readOnly: true
%{~ endif }
