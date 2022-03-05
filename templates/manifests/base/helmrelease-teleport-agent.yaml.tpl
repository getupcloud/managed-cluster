%{ if teleport_auth_token != "" ~}
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: teleport-agent
  namespace: flux-system
spec:
  chart:
    spec:
      chart: teleport-kube-agent
      sourceRef:
        kind: HelmRepository
        name: teleport
  install:
    createNamespace: true
    disableWait: true
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
