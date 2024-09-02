%{ if modules.kyverno.enabled ~}
---
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: kyverno
  namespace: flux-system
spec:
  chart:
    spec:
      chart: kyverno
      sourceRef:
        kind: HelmRepository
        name: kyverno
      version: "~> 2.5"
  install:
    createNamespace: true
    disableWait: true
    remediation:
      retries: -1
  upgrade:
    remediation:
      retries: -1
  interval: 5m
  releaseName: kyverno
  storageNamespace: kyverno
  targetNamespace: kyverno
  values:
    # HA requires at least 3 pods
    replicaCount: 1
    resources:
      limits:
        memory: 2Gi
%{~ if modules.kyverno.kyverno-policies.enabled }
---
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: kyverno-policies
  namespace: flux-system
spec:
  chart:
    spec:
      chart: kyverno-policies
      sourceRef:
        kind: HelmRepository
        name: kyverno
      version: "~> 2.5"
  install:
    createNamespace: true
    disableWait: true
    remediation:
      retries: -1
  upgrade:
    remediation:
      retries: -1
  interval: 5m
  releaseName: kyverno-policies
  storageNamespace: kyverno
  targetNamespace: kyverno
  values:
    validationFailureAction: audit
%{~ endif }
%{~ endif }
