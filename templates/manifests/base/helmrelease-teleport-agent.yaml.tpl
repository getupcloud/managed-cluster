%{~ if teleport_auth_token != "" }
%{~ if cluster_type == "okd" ~}
---
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: anyuid provides all features of the restricted SCC
      but allows users to run with any UID and any GID.
  name: teleport-agent
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegeEscalation: true
allowPrivilegedContainer: false
allowedCapabilities: null
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
groups:
- system:cluster-admins
priority: 10
readOnlyRootFilesystem: false
requiredDropCapabilities:
- MKNOD
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: RunAsAny
users:
- system:serviceaccount:getup:teleport-agent
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
%{~ endif }
---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: teleport-agent
  namespace: flux-system
spec:
  chart:
    spec:
      chart: teleport-kube-agent
      version: "<10"
      sourceRef:
        kind: HelmRepository
        name: teleport
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
  releaseName: teleport-agent
  storageNamespace: getup
  targetNamespace: getup
  values:
    proxyAddr: ${teleport_proxy_addr}
    authToken: ${teleport_auth_token}
    kubeClusterName: ${teleport_kube_cluster_name}

    labels:
      ${indent(6, yamlencode(teleport_labels))}

    tolerations:
    - key: dedicated
      value: infra
      effect: NoSchedule

    affinity:
      nodeAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          preference:
            matchExpressions:
            - key: node-role.kubernetes.io/infra
              operator: Exists
            - key: role
              operator: In
              values:
              - infra
%{~ endif }
