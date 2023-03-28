%{~ if modules.linkerd.enabled && modules.linkerd.linkerd-viz.enabled}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: linkerd-viz
  namespace: linkerd-viz
spec:
  ingressClassName: openshift-default
%{~ endif }
