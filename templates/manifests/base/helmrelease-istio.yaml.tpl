%{ if modules.istio.enabled ~}
---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: istio-base
  namespace: flux-system
spec:
  chart:
    spec:
      chart: base
      sourceRef:
        kind: HelmRepository
        name: istio
      version: "~> 1.16"
  install:
    createNamespace: true
    disableWait: false
    remediation:
      retries: -1
  upgrade:
    remediation:
      retries: -1
  interval: 5m
  releaseName: istio-base
  storageNamespace: istio-system
  targetNamespace: istio-system
  values: {}

---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: istio-istiod
  namespace: flux-system
spec:
  chart:
    spec:
      chart: istiod
      sourceRef:
        kind: HelmRepository
        name: istio
      version: "~> 1.16"
  install:
    createNamespace: false
    disableWait: false
    remediation:
      retries: -1
  upgrade:
    remediation:
      retries: -1
  interval: 5m
  releaseName: istiod
  storageNamespace: istio-system
  targetNamespace: istio-system
  dependsOn:
  - name: istio-base
  values:
    pilot:
      nodeSelector:
        node-role.kubernetes.io/infra: ""

      tolerations:
      - effect: NoSchedule
        operator: Exists

      # Resources for a small pilot install
      resources:
        requests:
          cpu: 500m
          memory: 2048Mi

    global:
      proxy:
        resources:
          limits:
            cpu: 256m
            memory: 384Mi

---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: istio-gateway
  namespace: flux-system
spec:
  chart:
    spec:
      chart: gateway
      sourceRef:
        kind: HelmRepository
        name: istio
      version: "~> 1.16"
  install:
    createNamespace: false
    disableWait: false
    remediation:
      retries: -1
  upgrade:
    remediation:
      retries: -1
  interval: 5m
  releaseName: istio-gateway
  storageNamespace: istio-system
  targetNamespace: istio-system
  dependsOn:
  - name: istio-istiod
  values:
    nodeSelector:
      node-role.kubernetes.io/infra: ""

    tolerations:
    - effect: NoSchedule
      operator: Exists
%{~ endif }
