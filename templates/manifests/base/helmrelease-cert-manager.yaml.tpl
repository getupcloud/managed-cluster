%{ if modules.cert-manager.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: cert-manager
  namespace: flux-system
spec:
  chart:
    spec:
      chart: cert-manager
      sourceRef:
        kind: HelmRepository
        name: jetstack
      version: "~> 1.8"
  dependsOn:
  - name: monitoring
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
  releaseName: cert-manager
  storageNamespace: cert-manager
  targetNamespace: cert-manager
  values:
    installCRDs: true

    prometheus:
      servicemonitor:
        enabled: true

    tolerations:
    - operator: Exists
      effect: NoSchedule

    affinity:
      nodeAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          preference:
            matchExpressions:
            - key: role
              operator: In
              values:
              - infra

    cainjector:
      tolerations:
      - operator: Exists
        effect: NoSchedule

      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - key: role
                operator: In
                values:
                - infra

    webhook:
      tolerations:
      - operator: Exists
        effect: NoSchedule

      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 100
            preference:
              matchExpressions:
              - key: role
                operator: In
                values:
                - infra
%{~ endif }
