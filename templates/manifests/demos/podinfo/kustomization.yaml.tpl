apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: podinfo

%{~ if modules.demos.podinfo.enabled }
resources:
- https://github.com/stefanprodan/podinfo//kustomize/kustomization.yaml
%{~ else }
resources: []
%{~ endif }
