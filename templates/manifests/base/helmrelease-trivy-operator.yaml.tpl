%{ if modules.trivy.enabled }
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: trivy-operator
  namespace: flux-system
spec:
  chart:
    spec:
      chart: trivy-operator
      sourceRef:
        kind: HelmRepository
        name: aqua
      version: "~> 0.4"
  install:
    createNamespace: true
    disableWait: true
    remediation:
      retries: -1
  upgrade:
    disableWait: false
    remediation:
      retries: -1
  interval: 5m
  releaseName: trivy-operator
  storageNamespace: trivy-system
  targetNamespace: trivy-system
  values:
    excludeNamespaces: "kube-system,trivy-system"

    operator:
      vulnerabilityScannerEnabled: true
      configAuditScannerEnabled: true
      rbacAssessmentScannerEnabled: true
      clusterComplianceEnabled: false
      accessGlobalSecretsAndServiceAccount: true
      metricsVulnIdEnabled: true
      metricsFindingsEnabled: true
      exposedSecretScannerEnabled: true

    trivy:
      ignoreUnfixed: false
      severity: UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL
      #severity: MEDIUM,HIGH,CRITICAL

    resources:
      requests:
        cpu: 100m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 512Mi

    serviceMonitor:
      enabled: true
      interval: "600s"
%{~ endif }
