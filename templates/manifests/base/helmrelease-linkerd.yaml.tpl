%{~ if try(modules.linkerd.enabled, false) }
%{~ if cluster_type == "okd" ~}
---
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  annotations:
    kubernetes.io/description: 'privileged allows access to all privileged and host
      features and the ability to run as any user, any group, any fsGroup, and with
      any SELinux context.  WARNING: this is the most relaxed SCC and should be used
      only for cluster administration. Grant with caution.'
  name: linkerd
allowHostDirVolumePlugin: true
allowHostIPC: true
allowHostNetwork: true
allowHostPID: true
allowHostPorts: true
allowPrivilegeEscalation: true
allowPrivilegedContainer: true
allowedCapabilities:
- '*'
allowedUnsafeSysctls:
- '*'
defaultAddCapabilities: null
fsGroup:
  type: RunAsAny
groups:
priority: null
readOnlyRootFilesystem: false
requiredDropCapabilities: null
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: RunAsAny
seccompProfiles:
- '*'
supplementalGroups:
  type: RunAsAny
users:
- system:serviceaccount:linkerd:default
- system:serviceaccount:linkerd:linkerd-destination
- system:serviceaccount:linkerd:linkerd-identity
- system:serviceaccount:linkerd:linkerd-proxy-injector
- system:serviceaccount:linkerd:linkerd-heartbeat
%{~ if try(modules.linkerd-cni.enabled, false) }
- system:serviceaccount:linkerd-cni:linkerd-cni
%{~ endif }
volumes:
- '*'
%{~ endif }

---
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    linkerd.io/inject: disabled
  labels:
    kubernetes.io/metadata.name: linkerd
    linkerd.io/control-plane-ns: linkerd
    linkerd.io/is-control-plane: "true"
    config.linkerd.io/admission-webhooks: disabled
  name: linkerd

---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: linkerd
  namespace: flux-system
spec:
  chart:
    spec:
      chart: linkerd2
      sourceRef:
        kind: HelmRepository
        name: linkerd
      version: 2.11.2
  install:
    createNamespace: false
    disableWait: false
    remediation:
      retries: -1
  interval: 30m
  releaseName: linkerd
  storageNamespace: linkerd
  targetNamespace: linkerd
  values:
    cniEnabled: ${ modules.linkerd-cni.enabled }
    installNamespace: false
    identityTrustAnchorsPEM: |-
      ${indent(6, trimspace(linkerd_ca_crt))}
    identity:
      issuer:
        tls:
          crtPEM: |-
            ${indent(12, trimspace(linkerd_issuer_crt))}
          keyPEM: |-
            ${indent(12, trimspace(linkerd_issuer_key))}
        crtExpiry: ${linkerd_issuer_crt_expiry}
%{~ endif }

%{~ if try(modules.linkerd-cni.enabled, false) }
---
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    linkerd.io/inject: disabled
  labels:
    kubernetes.io/metadata.name: linkerd-cni
  name: linkerd-cni

---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: linkerd-cni
  namespace: flux-system
spec:
  chart:
    spec:
      chart: linkerd2-cni
      sourceRef:
        kind: HelmRepository
        name: linkerd
      version: 2.11.2
  install:
    createNamespace: false
    disableWait: false
    remediation:
      retries: -1
  interval: 30m
  releaseName: linkerd-cni
  storageNamespace: linkerd-cni
  targetNamespace: linkerd-cni
  values:
    destCNIBinDir: /var/lib/cni/bin
    destCNINetDir: /etc/kubernetes/cni/net.d
    tolerations:
    - effect: NoSchedule
      operator: Exists
%{~ endif }
