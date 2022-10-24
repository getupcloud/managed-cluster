%{~ if try(modules.linkerd.enabled, false) }
%{~   if cluster_type == "okd" ~}
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
%{~     if try(modules.linkerd-cni.enabled, false) }
- system:serviceaccount:linkerd-cni:default
- system:serviceaccount:linkerd-cni:linkerd-cni
%{~     endif }
%{~     if try(modules.linkerd-viz.enabled, false) }
%{~       for sa in ["default", "grafana", "metrics-api", "prometheus", "tap", "tap-injector", "web"] }
- system:serviceaccount:linkerd-viz:${sa}
%{~       endfor }
%{~     endif }
volumes:
- '*'
%{~   endif }

##
## Linkerd Control Plane
##
---
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    linkerd.io/inject: disabled
  labels:
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
  upgrade:
    disableWait: false
    remediation:
      retries: -1
  interval: 30m
  releaseName: linkerd
  storageNamespace: linkerd
  targetNamespace: linkerd
%{~   if try(modules.linkerd-cni.enabled, false) }
  dependsOn:
  - name: linkerd-cni
%{~   endif }
  values:
    installNamespace: false
    clusterNetworks: 10.0.0.0/8,172.16.0.0/12,192.168.0.0/16,169.254.0.0/16
    cniEnabled: ${ modules.linkerd-cni.enabled }
    identityTrustAnchorsPEM: |-
      ${indent(6, trimspace(try(modules_output.linkerd.ca_crt, "")))}
    identity:
      issuer:
        tls:
          crtPEM: |-
            ${indent(12, trimspace(try(modules_output.linkerd.issuer_crt, "")))}
          keyPEM: |-
            ${indent(12, trimspace(try(modules_output.linkerd.issuer_key, "")))}
        crtExpiry: ${try(modules_output.linkerd.issuer_crt_expiry, "")}
%{~   if length(modules.linkerd.nodeSelector) > 0}
    nodeSelector:
      ${indent(6, yamlencode(modules.linkerd.nodeSelector))}
%{~   endif }
    tolerations:
    - effect: NoSchedule
      operator: Exists
%{~ endif }

%{~ if try(modules.linkerd-cni.enabled, false) }
##
## Linkerd CNI (required for OKD)
##
---
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    linkerd.io/inject: disabled
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
  upgrade:
    disableWait: false
    remediation:
      retries: -1
  interval: 30m
  releaseName: linkerd-cni
  storageNamespace: linkerd-cni
  targetNamespace: linkerd-cni
  values:
    installNamespace: false
    destCNIBinDir: /var/lib/cni/bin
    destCNINetDir: /etc/kubernetes/cni/net.d
%{~   if length(modules.linkerd.nodeSelector) > 0}
    nodeSelector:
      ${indent(6, yamlencode(modules.linkerd-cni.nodeSelector))}
%{~   endif }
    tolerations:
    - effect: NoSchedule
      operator: Exists
%{~ endif }

%{~ if try(modules.linkerd-viz.enabled, false) }
##
## Linkerd Viz
##
---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: linkerd-viz
  namespace: flux-system
spec:
  chart:
    spec:
      chart: linkerd-viz
      sourceRef:
        kind: HelmRepository
        name: linkerd
      version: 2.11.2
  install:
    createNamespace: false
    disableWait: false
    remediation:
      retries: -1
  upgrade:
    disableWait: false
    remediation:
      retries: -1
  interval: 30m
  releaseName: linkerd-viz
  ##
  ## We need all labels from chart's template for linkerd-viz namespace
  ##
  storageNamespace: flux-system
  targetNamespace: linkerd-viz
  dependsOn:
  - name: linkerd
  values:
    installNamespace: true
%{~   if length(modules.linkerd-viz.nodeSelector) > 0 }
    nodeSelector:
      ${indent(6, yamlencode(modules.linkerd-viz.nodeSelector))}
%{~   endif }
    tolerations:
    - effect: NoSchedule
      operator: Exists
%{~ endif }
