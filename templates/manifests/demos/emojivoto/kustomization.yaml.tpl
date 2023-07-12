apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

%{~ if modules.demos.emojivoto.enabled }
resources:
- emojivoto.yaml
%{~ else }
resources: []
%{~ endif }
