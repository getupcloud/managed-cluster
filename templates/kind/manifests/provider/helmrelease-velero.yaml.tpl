%{ if modules.velero.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: velero
  namespace: flux-system
spec:
  suspend: true
%{~ endif }
