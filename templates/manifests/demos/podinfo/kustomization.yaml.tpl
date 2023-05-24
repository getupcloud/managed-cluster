%{~ if modules.demos.podinfo.enabled }
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: podinfo

resources:
- https://github.com/stefanprodan/podinfo//kustomize/kustomization.yaml
%{ endif }
