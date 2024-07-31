%{~ if modules.linkerd.enabled }
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
%{~ if modules.linkerd.linkerd-cni.enabled }
- system:serviceaccount:linkerd-cni:default
- system:serviceaccount:linkerd-cni:linkerd-cni
%{~ endif }
%{~ if modules.linkerd.linkerd-viz.enabled }
- system:serviceaccount:linkerd-viz:builder
- system:serviceaccount:linkerd-viz:default
- system:serviceaccount:linkerd-viz:deployer
- system:serviceaccount:linkerd-viz:grafana
- system:serviceaccount:linkerd-viz:metrics-api
- system:serviceaccount:linkerd-viz:namespace-metadata
- system:serviceaccount:linkerd-viz:prometheus
- system:serviceaccount:linkerd-viz:tap
- system:serviceaccount:linkerd-viz:tap-injector
- system:serviceaccount:linkerd-viz:web
%{~ endif }
%{~ if modules.linkerd.linkerd-jaeger.enabled }
- system:serviceaccount:linkerd-jaeger:collector
- system:serviceaccount:linkerd-jaeger:jaeger
- system:serviceaccount:linkerd-jaeger:jaeger-injector
- system:serviceaccount:linkerd-jaeger:namespace-metadata
%{~ endif }
volumes:
- '*'
%{~ endif }

##
## Linkerd CRDS and Control Plane
##

---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: linkerd-crds
  namespace: flux-system
spec:
  chart:
    spec:
      chart: linkerd-crds
      sourceRef:
        kind: HelmRepository
        name: linkerd
      version: "~> 1.4"
  install:
    createNamespace: true
    disableWait: false
    remediation:
      retries: -1
  upgrade:
    disableWait: false
    remediation:
      retries: -1
  interval: 30m
  releaseName: linkerd-crds
  storageNamespace: linkerd
  targetNamespace: linkerd
  values:
    cniEnabled: ${ modules.linkerd.linkerd-cni.enabled }

---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: linkerd-control-plane
  namespace: flux-system
spec:
  chart:
    spec:
      chart: linkerd-control-plane
      sourceRef:
        kind: HelmRepository
        name: linkerd
      version: "~> 1.9"
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
  releaseName: linkerd-control-plane
  storageNamespace: linkerd
  targetNamespace: linkerd
  dependsOn:
  - name: linkerd-crds
%{~   if modules.linkerd.linkerd-cni.enabled }
  - name: linkerd-cni
%{~   endif }
  values:
    clusterNetworks: 10.0.0.0/8,100.64.0.0/10,172.16.0.0/12,192.168.0.0/16
    cniEnabled: ${ modules.linkerd.linkerd-cni.enabled }

    tolerations:
    - key: dedicated
      value: infra
      effect: NoSchedule

    proxyInit:
      runAsRoot: true
      resources:
        cpu:
          limit: 100m
          #request: 10m
        memory:
          limit: 50Mi
          #request: 15Mi

    podMonitor:
      enabled: true
      scrapeInterval: "30s"
      serviceMirror:
        enabled: false

%{~ if modules.linkerd.linkerd-jaeger.enabled }
    controlPlaneTracing: true
    controlPlaneTracingNamespace: linkerd-jaeger
%{~ endif }

%{ if try(modules.linkerd.output.ca_crt, "") != "" }
    identityTrustAnchorsPEM: |-
      ${indent(6, trimspace(try(modules.linkerd.output.ca_crt, "")))}
    identity:
      issuer:
        tls:
          crtPEM: |-
            ${indent(12, trimspace(try(modules.linkerd.output.issuer_crt, "")))}
          keyPEM: |-
            ${indent(12, trimspace(try(modules.linkerd.output.issuer_key, "")))}
        crtExpiry: ${try(modules.linkerd.output.issuer_crt_expiry, "")}
%{~   endif }

%{~ if modules.linkerd.linkerd-cni.enabled || cluster_type == "okd" ~}
##
## Linkerd CNI (required for OKD).
## https://linkerd.io/2.12/features/cni/
##

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
      version: "~> 30.3"
  install:
    createNamespace: true
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
    destCNIBinDir: /var/lib/cni/bin
    destCNINetDir: /etc/kubernetes/cni/net.d

    nodeSelector:

    tolerations:
    - key: dedicated
      value: infra
      effect: NoSchedule
%{~ endif }

%{~ if modules.linkerd.linkerd-viz.enabled }
##
## Linkerd Viz
##
---
# We need this in order to create ingress/secret for Viz
apiVersion: v1
kind: Namespace
metadata:
  labels:
    kubernetes.io/metadata.name: linkerd-viz
    linkerd.io/extension: viz
    name: linkerd-viz
    linkerd.io/inject: disabled
  name: linkerd-viz
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-production-http01
    nginx.ingress.kubernetes.io/auth-realm: Authentication Required
    nginx.ingress.kubernetes.io/auth-secret: linkerd-viz-basic-auth
    nginx.ingress.kubernetes.io/auth-type: basic
  name: linkerd-viz
  namespace: linkerd-viz
spec:
  ingressClassName: ${ cluster_type == "okd" ? "openshift-default" : "nginx" }
  rules:
  - host: ${modules.linkerd.linkerd-viz.hostname}
    http:
      paths:
      - backend:
          service:
            name: web
            port:
              number: 8084
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - ${modules.linkerd.linkerd-viz.hostname}
    secretName: web-tls
---
apiVersion: v1
kind: Secret
metadata:
  name: linkerd-viz-basic-auth
  namespace: linkerd-viz
type: Opaque
data:
  auth: ${base64encode(modules.linkerd.output.linkerd-viz-htpasswd)}
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
      version: "~> 30.3"
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
  storageNamespace: linkerd-viz
  targetNamespace: linkerd-viz
  dependsOn:
  - name: linkerd-control-plane
%{~ if modules.linkerd.linkerd-jaeger.enabled }
  - name: linkerd-jaeger
%{~ endif }
  values:
    dashboard:
      enforcedHostRegexp: ".*"
      prometheusUrl: "http://monitoring-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090"
%{~ if modules.linkerd.linkerd-jaeger.enabled }
    jaegerUrl: "jaeger.linkerd-jaeger.svc:16686"
%{~ endif }
    grafana:
      externalUrl: ${ modules.monitoring.grafana.ingress.scheme }://${ modules.monitoring.grafana.ingress.host }

    tolerations:
    - key: dedicated
      value: infra
      effect: NoSchedule
%{~ endif }

%{~ if modules.linkerd.linkerd-jaeger.enabled }
---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: linkerd-jaeger
  namespace: flux-system
spec:
  chart:
    spec:
      chart: linkerd-jaeger
      sourceRef:
        kind: HelmRepository
        name: linkerd
      version: "~> 30.4"
  dependsOn:
  - name: linkerd-control-plane
  install:
    createNamespace: true
    disableWait: false
    remediation:
      retries: -1
  upgrade:
    remediation:
      retries: -1
  interval: 5m
  releaseName: linkerd-jaeger
  storageNamespace: linkerd-jaeger
  targetNamespace: linkerd-jaeger
  values: {}
%{~ endif }
%{~ endif }
