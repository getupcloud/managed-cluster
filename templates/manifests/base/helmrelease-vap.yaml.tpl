%{ if modules.vap.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: vap
  namespace: flux-system
spec:
  chart:
    spec:
      chart: vap
      sourceRef:
        kind: HelmRepository
        name: getupcloud
      version: "~> 0"
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
  storageNamespace: vap-system
  targetNamespace: vap-system
  releaseName: vap
  values:
    enforce: %{ modules.vap.enforce }

    %{~ if modules.vap.enforce }
    defaultFailurePolicy: Fail
    %{~ else }
    defaultFailurePolicy: Ignore
    %{~ endif }
%{~ endif }
