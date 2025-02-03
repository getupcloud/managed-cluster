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
    %{~ if modules.vap.enforce }
    defaultFailurePolicy: Fail
    %{~ else }
    defaultFailurePolicy: Ignore
    %{~ endif }

    bindingSpec:
      matchResources:
        # matchPolicy: Equivalent
        namespaceSelector:
          matchLabels:
            vap.getup.io/enabled: "true"
        objectSelector: {}
      policyName: '{{ .policyName }}'
      validationActions:
      %{~ if modules.vap.enforce ~}
      - Deny
      - Audit
      %{~ else }
      - Warn
      %{~ endif }
%{~ endif }
