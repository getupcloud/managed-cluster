%{ if modules.velero.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: velero
  namespace: flux-system
spec:
  suspend: true
%{~ endif }
