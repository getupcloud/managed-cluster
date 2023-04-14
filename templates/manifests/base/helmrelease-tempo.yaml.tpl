%{~ if modules.monitoring.tempo.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: tempo
  namespace: flux-system
spec:
  chart:
    spec:
      chart: tempo
      sourceRef:
        kind: HelmRepository
        name: grafana
      version: "~> 1.0"
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
  releaseName: tempo
  storageNamespace: monitoring
  targetNamespace: monitoring
  values:
    affinity:
      nodeAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          preference:
            matchExpressions:
            - key: node-role.kubernetes.io/infra
              operator: Exists
        - weight: 90
          preference:
            matchExpressions:
            - key: role
              operator: In
              values:
              - infra

    tolerations:
    - operator: Exists
      effect: NoSchedule

    persistence:
      enabled: true
      size: 50Gi

    serviceMonitor:
      enabled: true
      interval: 30s

    tempo:
      multitenancyEnabled: false
      retention: 48h
      metricsGenerator:
        enabled: true
        remoteWriteUrl: "http://monitoring-kube-prometheus-prometheus:9090/api/v1/write"
%{~ endif ~}
