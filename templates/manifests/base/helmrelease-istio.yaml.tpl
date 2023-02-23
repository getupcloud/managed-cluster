%{ if modules.istio.enabled ~}

###########
## Istio ##
###########

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
  name: istio-ingressgateway
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
  releaseName: istio-ingressgateway
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

%{ if modules.istio.kiali.enabled ~}

###########
## Kiali ##
###########

---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: kiali-operator
  namespace: flux-system
spec:
  chart:
    spec:
      chart: kiali-operator
      sourceRef:
        kind: HelmRepository
        name: kiali
      version: "~> 1"
  install:
    createNamespace: true
    disableWait: false
    remediation:
      retries: -1
  upgrade:
    remediation:
      retries: -1
  interval: 5m
  releaseName: kiali-operator
  storageNamespace: kiali-operator
  targetNamespace: kiali-operator
  values:
    cr:
      create: true
      namespace: istio-system

---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: kiali
  namespace: flux-system
spec:
  chart:
    spec:
      chart: templater
      sourceRef:
        kind: HelmRepository
        name: getupcloud
      version: "~> 1"
  install:
    createNamespace: false
    disableWait: false
    remediation:
      retries: -1
  upgrade:
    remediation:
      retries: -1
  interval: 5m
  releaseName: kiali
  storageNamespace: istio-system
  targetNamespace: istio-system
  dependsOn:
  - name: kiali-operator
  values:
    templates:
    - |-
      apiVersion: kiali.io/v1alpha1
      kind: Kiali
      metadata:
        name: kiali
        namespace: istio-system
      spec:
        auth:
          strategy: anonymous

    - |-
      apiVersion: networking.istio.io/v1beta1
      kind: Gateway
      metadata:
        name: kiali
        namespace: istio-system
      spec:
        selector:
          istio: ingressgateway
        servers:
        - hosts:
          - ${ modules.istio.kiali.ingress.host }
          port:
            name: ${ modules.istio.kiali.ingress.port.name }
            number: ${ modules.istio.kiali.ingress.port.number }
            protocol: ${ modules.istio.kiali.ingress.port.protocol }

    - |-
      apiVersion: networking.istio.io/v1beta1
      kind: VirtualService
      metadata:
        name: kiali
        namespace: istio-system
      spec:
        gateways:
        - kiali
        hosts:
        - ${ modules.istio.kiali.ingress.host }
        http:
        - route:
          - destination:
              host: kiali
              port:
                number: 20001
%{~ endif }
%{~ endif }
