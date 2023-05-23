%{~ if modules.demos.tns.enabled }
# Source https://github.com/getupcloud/demo-observability/tree/main/tns/k8s-yamls
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- app-dep.yaml
- app-ing.yaml
- app-svc.yaml
- db-dep.yaml
- db-svc.yaml
- kustomization.yaml.tpl
- loadgen-dep.yaml
- loadgen-svc.yaml
- tns-servicemonitor.yaml
%{~ endif }
