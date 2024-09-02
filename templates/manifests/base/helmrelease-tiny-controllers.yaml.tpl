%{ if modules.tiny-controllers.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: cert-manager
  namespace: flux-system
spec:
  chart:
    spec:
      chart: tiny-controllers
      sourceRef:
        kind: HelmRepository
        name: getupcloud
      version: "~> 0.1"
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
  releaseName: tiny-controllers
  storageNamespace: tiny-controllers
  targetNamespace: tiny-controllers
  values:
    controllers:
      job:
        enabled: false
        env: []
      node:
        enabled: false
        env: []
      patch:
        enabled: false
      volume:
        enabled: false
%{~ endif }
