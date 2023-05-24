%{~ if modules.demos.emojivoto.enabled }
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- emojivoto.yaml
%{ endif }
