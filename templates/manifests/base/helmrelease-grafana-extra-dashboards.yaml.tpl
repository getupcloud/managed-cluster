apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: grafana-extra-dashboards
  namespace: flux-system
spec:
  chart:
    spec:
      chart: grafana-extra-dashboards
      sourceRef:
        kind: HelmRepository
        name: getupcloud
      version: "~> 0.2"
  dependsOn:
    - name: monitoring
  install:
    createNamespace: true
    disableWait: true
    remediation:
      retries: -1
  upgrade:
    disableWait: true
    remediation:
      retries: -1
  interval: 5m
  storageNamespace: monitoring
  targetNamespace: monitoring
  releaseName: grafana-extra-dashboards
  values:
    default:
      enabled: true

    linkerd:
      enabled: ${ try(modules.linkerd.enabled, false) }

    rabbitmq:
      enabled: true
