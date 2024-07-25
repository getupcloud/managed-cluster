%{ if modules.x509-exporter.enabled ~}
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
    # Monitors certificates from secrets
    # https://github.com/enix/x509-certificate-exporter/tree/main/deploy/charts/x509-certificate-exporter#metrics-for-tls-secrets
    secretsExporter:
      enabled: true
%{ if cluster_type == "okd" ~}
      securityContext:
        runAsGroup: null
        runAsUser: null
%{~ endif }

    # Monitors certificates from node's filesystem
    # https://github.com/enix/x509-certificate-exporter/tree/main/deploy/charts/x509-certificate-exporter#metrics-for-node-certificates-hostpath
    hostPathsExporter:
      daemonSets:
        controlplane:
          nodeSelector:
            node-role.kubernetes.io/master: ""
          tolerations:
          - effect: NoSchedule
            operator: Exists
          watchFiles:
          - /var/lib/kubelet/pki/kubelet-client-current.pem
          - /etc/kubernetes/pki/apiserver.crt
          - /etc/kubernetes/pki/apiserver-etcd-client.crt
          - /etc/kubernetes/pki/apiserver-kubelet-client.crt
          - /etc/kubernetes/pki/ca.crt
          - /etc/kubernetes/pki/front-proxy-ca.crt
          - /etc/kubernetes/pki/front-proxy-client.crt
          - /etc/kubernetes/pki/etcd/ca.crt
          - /etc/kubernetes/pki/etcd/healthcheck-client.crt
          - /etc/kubernetes/pki/etcd/peer.crt
          - /etc/kubernetes/pki/etcd/server.crt
          watchKubeconfFiles:
          - /etc/kubernetes/admin.conf
          - /etc/kubernetes/controller-manager.conf
          - /etc/kubernetes/scheduler.conf

        nodes:
          tolerations:
          - effect: NoSchedule
            operator: Exists
          watchFiles:
          - /var/lib/kubelet/pki/kubelet-client-current.pem
          - /etc/kubernetes/pki/ca.crt

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
%{~ endif }
