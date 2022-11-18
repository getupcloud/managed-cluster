%{ if modules.alb.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: aws-load-balancer-controller
  namespace: flux-system
spec:
  chart:
    spec:
      chart: aws-load-balancer-controller
      sourceRef:
        kind: HelmRepository
        name: eks
      version: "~1"
  install:
    createNamespace: true
    disableWait: false
    remediation:
      retries: -1
  upgrade:
    remediation:
      retries: -1
  interval: 5m
  releaseName: aws-load-balancer-controller
  storageNamespace: kube-system
  targetNamespace: kube-system
  values:
    clusterName: ${cluster_name}
    ingressClass: ${modules.alb.ingressClass}

    serviceMonitor:
      enabled: true

%{~ if modules.alb.output.iam_role_arn != ""}
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${try(modules.alb.output.iam_role_arn, "")}
%{~ endif }
%{~ endif }
