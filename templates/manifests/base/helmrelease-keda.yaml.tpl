%{ if modules.keda.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: keda
  namespace: flux-system
spec:
  chart:
    spec:
      chart: keda
      sourceRef:
        kind: HelmRepository
        name: kedacore
      version: "~> 2.15"
  #dependsOn:
  #  - name: cert-manager
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
  releaseName: keda
  storageNamespace: keda
  targetNamespace: keda
  values:
    operator:
      replicaCount: 2
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: node-role.kubernetes.io/infra
              operator: Exists
%{~ endif }
