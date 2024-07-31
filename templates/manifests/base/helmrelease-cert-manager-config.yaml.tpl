%{ if modules.cert-manager-config.enabled ~}
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
      version: "~> 0.2"
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
    ingress_class: ${ cluster_type == "okd" ? "openshift-default" : modules.cert-manager-config.ingress_class }

    cluster_issuer_selfsigned:
      enabled: true

    cluster_issuer_letsencrypt:
      enabled: true

    cluster_issuer_dns01:
      enabled: false
      aws_region: ""
      aws_zones: ""
      aws_access_key_id: ""

    %{~ if modules.cert-manager-config.cloudflare_enabled }
    cluster_issuer_dns01_cloudflare:
      enabled: true
      cloudflare_zones:
      %{~ for zone in modules.cert-manager-config.cloudflare_zones }
      - ${ zone }
      %{~ endfor }
      cloudflare_email: ${ modules.cert-manager-config.cloudflare_email }
      cloudflare_token: ${ modules.cert-manager-config.cloudflare_token }
    %{~ endif }

%{~ endif }
