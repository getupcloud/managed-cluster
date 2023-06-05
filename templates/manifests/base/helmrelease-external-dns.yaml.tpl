%{ if modules.external-dns.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: external-dns
  namespace: flux-system
spec:
  chart:
    spec:
      chart: external-dns
      sourceRef:
        kind: HelmRepository
        name: external-dns
      version: "~> 1.11"
  install:
    createNamespace: true
    disableWait: false
    remediation:
      retries: -1
  interval: 5m
  releaseName: external-dns
  storageNamespace: external-dns
  targetNamespace: external-dns
  values:
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

    tolerations:
    - key: dedicated
      value: infra
      effect: NoSchedule

%{~ if length(modules.external-dns.domain_filters) > 0 }
    domainFilters:
%{~   for i in modules.external-dns.domain_filters }
      - ${ i }
%{~   endfor }
%{~ endif }

    policy: sync
%{~ endif }
