%{ if modules.external-dns.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: external-dns
  namespace: flux-system
spec:
  values:
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${modules.external-dns.output.iam_role_arn}
    provider: aws
    extraArgs:
%{~ if modules.external-dns.private }
      - --aws-zone-type=private
      - --annotation-filter=type=private
%{~ endif }
%{~ endif }

