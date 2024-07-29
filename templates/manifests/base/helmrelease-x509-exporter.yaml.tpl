%{ if modules.x509-exporter.enabled ~}
apiVersion: v1
kind: Namespace
metadata:
  name: x509-exporter
  labels:
    openshift.io/cluster-monitoring: "true"
---
%{~ if cluster_type == "okd" }
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
---
%{~ endif }
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
  values:
    # Monitors certificates from node's filesystem
    # https://github.com/enix/x509-certificate-exporter/tree/main/deploy/charts/x509-certificate-exporter#metrics-for-node-certificates-hostpath
    # !! auto-generated from script x509-exporter-config-builder.sh !!
    hostPathsExporter:
      daemonSets:
        securityContext:
          allowPrivilegeEscalation: true
          privileged: true
          readOnlyRootFilesystem: true
          runAsGroup: 0
          runAsUser: 0
          capabilities:
            drop:
            - ALL
%{~ if cluster_type == "okd" }
          seLinuxOptions:
            level: s0
            user: system_u
%{~ endif }

        controlplane:
          nodeSelector:
            node-role.kubernetes.io/master: ""
          tolerations:
          - effect: NoSchedule
            operator: Exists

%{~ if cluster_type == "okd" }
          watchDirectories:
          - /etc/kubernetes/static-pod-resources/etcd-certs/configmaps/etcd-metrics-proxy-client-ca
          - /etc/kubernetes/static-pod-resources/etcd-certs/configmaps/etcd-metrics-proxy-serving-ca
          - /etc/kubernetes/static-pod-resources/etcd-certs/configmaps/etcd-peer-client-ca
          - /etc/kubernetes/static-pod-resources/etcd-certs/configmaps/etcd-serving-ca
          - /etc/kubernetes/static-pod-resources/etcd-certs/secrets/etcd-all-certs
          - /etc/kubernetes/static-pod-resources/kube-apiserver-certs/configmaps/aggregator-client-ca
          - /etc/kubernetes/static-pod-resources/kube-apiserver-certs/configmaps/client-ca
          - /etc/kubernetes/static-pod-resources/kube-apiserver-certs/configmaps/trusted-ca-bundle
          - /etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/aggregator-client
          - /etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/check-endpoints-client-cert-key
          - /etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/control-plane-node-admin-client-cert-key
          - /etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/external-loadbalancer-serving-certkey
          - /etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/internal-loadbalancer-serving-certkey
          - /etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/kubelet-client
          - /etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/localhost-serving-cert-certkey
          - /etc/kubernetes/static-pod-resources/kube-apiserver-certs/secrets/service-network-serving-certkey
          - /etc/kubernetes/static-pod-resources/kube-controller-manager-certs/configmaps/aggregator-client-ca
          - /etc/kubernetes/static-pod-resources/kube-controller-manager-certs/configmaps/client-ca
          - /etc/kubernetes/static-pod-resources/kube-controller-manager-certs/configmaps/trusted-ca-bundle
          - /etc/kubernetes/static-pod-resources/kube-controller-manager-certs/secrets/csr-signer
          - /etc/kubernetes/static-pod-resources/kube-controller-manager-certs/secrets/kube-controller-manager-client-cert-key
          - /etc/kubernetes/static-pod-resources/kube-scheduler-certs/secrets/kube-scheduler-client-cert-key
%{~ endif }
%{~ if cluster_type == "kubespray" }
          watchDirectories:
          - /etc/kubernetes/ssl
          - /var/lib/kubelet/pki

          watchKubeconfFiles:
          - /etc/kubernetes/admin.conf
          - /etc/kubernetes/controller-manager.conf
          - /etc/kubernetes/kubelet.conf
          - /etc/kubernetes/scheduler.conf
%{~ endif }

        nodes:
          tolerations:
          - effect: NoSchedule
            operator: Exists

%{~ if cluster_type == "okd" }
          watchDirectories:
          - /var/lib/kubelet/pki

          watchKubeconfFiles:
          - /etc/kubernetes/kubeconfig
          - /etc/kubernetes/kubelet.conf
%{~ endif }
%{~ if cluster_type == "kubespray" }
          watchDirectories:
          - /etc/kubernetes/ssl
          - /var/lib/kubelet/pki

          watchKubeconfFiles:
          - /etc/kubernetes/kubelet.conf
%{~ endif }

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

    rbac:
      secretsExporter:
        serviceAccountName: x509-exporter-secrets
      hostPathsExporter:
        serviceAccountName: x509-exporter-hostpaths # must match RoleBinding for OKD clusters
%{~ endif }
