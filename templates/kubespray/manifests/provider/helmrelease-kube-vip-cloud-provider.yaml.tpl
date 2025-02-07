%{ if modules.kube-vip.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: kube-vip-cloud-controller
  namespace: flux-system
spec:
  chart:
    spec:
      chart: templater
      sourceRef:
        kind: HelmRepository
        name: getupcloud
      version: "~> 0.0"
  install:
    createNamespace: true
    disableWait: false
    remediation:
      retries: -1
  upgrade:
    remediation:
      retries: -1
  interval: 5m
  releaseName: kube-vip-cloud-controller
  storageNamespace: kube-system
  targetNamespace: kube-system
  values:
    cm:
      data:
        %{ for name, cidr in modules.kube-vip.cidrs ~}
        cidr-${ name }: ${ cidr }
        %{ endfor ~}
        %{ for name, range in modules.kube-vip.ranges ~}
        range-${ name }: ${ range }
        %{ endfor ~}
%{~ endif }
