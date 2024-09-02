%{ if modules.monitoring.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: monitoring-config
  namespace: flux-system
spec:
  chart:
    spec:
      chart: monitoring-config
      sourceRef:
        kind: HelmRepository
        name: getupcloud
      version: "~> 2"
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
  storageNamespace: monitoring
  targetNamespace: monitoring
  releaseName: monitoring-config
  values:
    cronitor:
      prometheusRules:
        enabled: true

    velero:
      prometheusRules:
        enabled: false

    rabbitmq:
      prometheusRules:
        enabled: false

    loki:
      prometheusRules:
        enabled: true
        canary:
          enabled: false
      ingress:
        basicAuth:
          enabled: false
          secretName: loki-basic-auth
          secretNamespace: logging
          #username: "logging"
          #password: "logging"

    prometheusStack:
      prometheusRules:
        enabled: true
      ingress:
        basicAuth:
          enabled: false
          secretName: monitoring-basic-auth
          secretNamespace: monitoring
          #username: "monitoring"
          #password: "monitoring"
%{~ endif }
