%{ if modules.kyverno.enabled || modules.trivy.enabled }
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: policy-reporter
  namespace: flux-system
spec:
  chart:
    spec:
      chart: policy-reporter
      sourceRef:
        kind: HelmRepository
        name: policy-reporter
      version: "~> 2.13"
  dependsOn:
  - name: kyverno
  install:
    createNamespace: true
    disableWait: true
    remediation:
      retries: -1
  upgrade:
    disableWait: false
    remediation:
      retries: -1
  interval: 5m
  releaseName: policy-reporter
  storageNamespace: kyverno
  targetNamespace: kyverno
  values:
    kyvernoPlugin:
      enabled: true
    ui:
      enabled: true
      plugins:
        kyverno: true
    target:
      loki:
        host: "http://loki.logging.svc.cluster.local:3100"
        path: "/loki/api/v1/push"
        minimumPriority: "warning"
        skipExistingOnStartup: true
        sources:
        - kyverno
%{~ endif }
