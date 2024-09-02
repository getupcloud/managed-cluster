%{ if modules.cert-manager.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: cert-manager
  namespace: flux-system
spec:
  values:
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${modules.cert-manager.output.iam_role_arn}
%{~ endif }
