%{ if modules.cert-manager.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: cert-utils-operator
  namespace: flux-system
spec:
  chart:
    spec:
      chart: cert-utils-operator
      sourceRef:
        kind: HelmRepository
        name: cert-utils-operator
      version: "~> 1.3"
  dependsOn:
  - name: cert-manager
  install:
    createNamespace: false
    disableWait: false
    remediation:
      retries: -1
  upgrade:
    disableWait: false
    remediation:
      retries: -1
  interval: 5m
  releaseName: cert-utils-operator
  storageNamespace: cert-manager
  targetNamespace: cert-manager
  values:
    enableCertManager: true
%{~ endif }
