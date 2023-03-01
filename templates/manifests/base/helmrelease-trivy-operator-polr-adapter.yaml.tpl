%{ if modules.trivy.enabled }
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: trivy-operator-polr-adapter
  namespace: flux-system
spec:
  chart:
    spec:
      chart: trivy-operator-polr-adapter
      sourceRef:
        kind: HelmRepository
        name: trivy-operator-polr-adapter
      version: "~> 0.3"
  dependsOn:
  - name: trivy-operator
  - name: policy-reporter
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
  releaseName: trivy-operator-polr-adapter
  storageNamespace: trivy-system
  targetNamespace: trivy-system
  values:
    adapters:
      exposedSecretReports:
        enabled: true
      rbacAssessmentReports:
        enabled: true
%{~ endif }
