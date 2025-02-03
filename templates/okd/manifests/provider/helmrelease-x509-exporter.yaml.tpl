# from base/helmrelease-x509-exporter.yaml.tpl
%{ if modules.x509-exporter.enabled ~}
apiVersion: v1
kind: Namespace
metadata:
  name: x509-exporter
  labels:
    openshift.io/cluster-monitoring: "true"
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: system:openshift:scc:anyuid
  namespace: x509-exporter
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:openshift:scc:anyuid
subjects:
- kind: ServiceAccount
  name: x509-exporter-hostpaths
  namespace: x509-exporter
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: system:openshift:scc:privileged
  namespace: x509-exporter
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:openshift:scc:privileged
subjects:
- kind: ServiceAccount
  name: x509-exporter-hostpaths
  namespace: x509-exporter
- kind: ServiceAccount
  name: x509-exporter-secrets
  namespace: x509-exporter
---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: x509-exporter
  namespace: flux-system
spec:
  chart:
    spec:
      chart: x509-certificate-exporter
      sourceRef:
        kind: HelmRepository
        name: enix
      version: "~> 3"
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
  storageNamespace: x509-exporter
  targetNamespace: x509-exporter
  releaseName: x509-exporter
  dependsOn:
  - name: x509-exporter-discovery
  valuesFrom:
  - kind: ConfigMap
    name: host-paths-exporter-controlplane-values
    optional: true
  - kind: ConfigMap
    name: host-paths-exporter-node-values
    optional: true
  values:
    # Monitors certificates from node's filesystem
    # https://github.com/enix/x509-certificate-exporter/tree/main/deploy/charts/x509-certificate-exporter#metrics-for-node-certificates-hostpath
    # !! auto-generated from script x509-exporter-config-builder.sh !!
    hostPathsExporter:
      securityContext:
        allowPrivilegeEscalation: true
        privileged: true
        readOnlyRootFilesystem: true
        runAsGroup: 0
        runAsUser: 0
        capabilities:
          drop:
          - ALL
        seLinuxOptions:
          level: s0
          user: system_u

    # Monitors certificates from secrets
    # https://github.com/enix/x509-certificate-exporter/tree/main/deploy/charts/x509-certificate-exporter#metrics-for-tls-secrets
    secretsExporter:
      enabled: true

    #  If you don't use the Prometheus operator at all, and don't have the CRD, disable resource creation and perhaps add Pod annotations for scrapping :
    #secretsExporter:
    #  podAnnotations:
    #    prometheus.io/port: "9793"
    #    prometheus.io/scrape: "true"
    #service:
    #  create: false
    #prometheusServiceMonitor:
    #  create: false
    #prometheusRules:
    #  create: false

    prometheusServiceMonitor:
      create: true
      scrapeInterval: 600s
    prometheusRules:
      create: true
      warningDaysLeft: 14
      criticalDaysLeft: 7

    rbac:
      secretsExporter:
        serviceAccountName: x509-exporter-secrets
      hostPathsExporter:
        serviceAccountName: x509-exporter-hostpaths # must match RoleBinding for OKD clusters
---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: x509-exporter-discovery
  namespace: flux-system
spec:
  chart:
    spec:
      chart: x509-exporter-discovery
      sourceRef:
        kind: HelmRepository
        name: getupcloud
      # version: "~> 3"
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
  storageNamespace: x509-exporter
  targetNamespace: x509-exporter
  releaseName: x509-exporter-discovery
  values:
    okd: true
    configMap:
        namespace: flux-system
%{~ endif }
