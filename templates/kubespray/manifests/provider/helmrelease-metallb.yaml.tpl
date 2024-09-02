%{ if modules.metallb.enabled ~}
---
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: metallb
  namespace: flux-system
spec:
  chart:
    spec:
      chart: metallb
      sourceRef:
        kind: HelmRepository
        name: metallb
      version: "~> 0.13"
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
  releaseName: metallb
  storageNamespace: metallb
  targetNamespace: metallb
  values:
    prometheus:
      namespace: monitoring
      serviceAccount: monitoring-kube-prometheus-prometheus
      serviceMonitor:
        enabled: true
        # interval: 5m ## waiting for https://github.com/metallb/metallb/pull/1857
      prometheusRule:
        enabled: true

    controller:
      tolerations:
        - effect: NoSchedule
          operator: Exists
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
          - weight: 90
            preference:
              matchExpressions:
              - key: node-role.kubernetes.io/infra
                operator: Exists

    speaker:
      frr:
        enabled: false
      tolerations:
        - effect: NoSchedule
          operator: Exists
---
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: metallb-config
  namespace: flux-system
spec:
  chart:
    spec:
      chart: templater
      sourceRef:
        kind: HelmRepository
        name: getupcloud
      version: "~> 1"
  dependsOn:
    - name: metallb
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
  releaseName: metallb-config
  storageNamespace: metallb
  targetNamespace: metallb
  values:
    templates:
    - |-
      apiVersion: metallb.io/v1beta1
      kind: IPAddressPool
      metadata:
        name: metallb
        namespace: metallb
      spec:
        addresses:
      %{~ for range in modules.metallb.addresses }
        - ${ range }
      %{~ endfor }
    - |-
      apiVersion: metallb.io/v1beta1
      kind: L2Advertisement
      metadata:
        name: metallb
        namespace: metallb
      spec:
        ipAddressPools:
        - metallb
%{~ endif }
