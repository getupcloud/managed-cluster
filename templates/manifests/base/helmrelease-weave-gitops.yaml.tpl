%{ if modules.weave-gitops.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: weave-gitops
  namespace: flux-system
spec:
  chart:
    spec:
      chart: weave-gitops
      sourceRef:
        kind: HelmRepository
        name: weave-gitops
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
  releaseName: weave-gitops
  storageNamespace: weave-gitops
  targetNamespace: weave-gitops
  values:
    adminUser:
      create: true
      username: ${ try(modules.weave-gitops.output.admin-username )}
      passwordHash: ${ try(modules.weave-gitops.output.admin-password-hash)}
    metrics:
      enabled: ${ modules.monitoring.enabled }
%{~ endif }
