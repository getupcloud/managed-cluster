apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: cert-manager-config
  namespace: flux-system
spec:
  chart:
    spec:
      chart: cert-manager-config
      sourceRef:
        kind: HelmRepository
        name: getupcloud
  dependsOn:
    - name: cert-manager
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
  releaseName: cert-manager-config
  storageNamespace: cert-manager
  targetNamespace: cert-manager
  values:
    acme_email: ${ modules.cert-manager-config.acme_email }
    ingress_class: ${ modules.cert-manager-config.ingress_class }

    cluster_issuer_selfsigned:
      enabled: true

    cluster_issuer_letsencrypt:
      enabled: true

    cluster_issuer_dns01:
      enabled: false
      aws_region: ""
      aws_zones: ""
      aws_access_key_id: ""
