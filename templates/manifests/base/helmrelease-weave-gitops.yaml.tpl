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
      version: "~> 4.0"
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
      username: ${ modules.weave-gitops.admin-username }
      passwordHash: ${ modules.weave-gitops.output.admin-password-hash }
    metrics:
      enabled: true
%{~ endif }
