%{~ if modules.kube-opex-analytics.enabled }
%{ if cluster_type == "okd" ~}
---
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: anyuid provides all features of the restricted SCC
      but allows users to run with any UID and any GID.
  name: kube-opex-analytics
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: false
allowPrivilegedContainer: false
allowedCapabilities: null
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
groups:
priority: 10
readOnlyRootFilesystem: true
requiredDropCapabilities:
- MKNOD
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
users:
- system:serviceaccount:kube-opex-analytics:kube-opex-analytics
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
%{~ endif }
---
apiVersion: v1
kind: Namespace
metadata:
  name: kube-opex-analytics
---
apiVersion: v1
data:
  KOA_GOOGLE_API_KEY: ""
kind: Secret
metadata:
  name: kube-opex-analytics-secrets
  namespace: kube-opex-analytics
---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: kube-opex-analytics
  namespace: flux-system
spec:
  chart:
    spec:
      chart: kube-opex-analytics
      sourceRef:
        kind: HelmRepository
        name: getupcloud
      version: "22.02.3"
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
  storageNamespace: kube-opex-analytics
  targetNamespace: kube-opex-analytics
  releaseName: kube-opex-analytics
  values:
    envs:
      KOA_COST_MODEL: RATIO
      KOA_BILLING_CURRENCY_SYMBOL: "R$"

    nodeSelector:
      role: infra

    tolerations:
    - effect: NoSchedule
      operator: Exists
%{~ endif }
