apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
# Do not include all from ../base in order to use openshift native monitoring system
- helmrepository.yaml
- helmrelease-monitoring-config.yaml
- helmrelease-teleport-agent.yaml
- helmrelease-x509-exporter.yaml
- openshift-helmrepository.yaml
- openshift-operators-namespace.yaml
- openshift-cert-manager.yaml
- openshift-adp.yaml
- openshift-logging.yaml
- openshift-monitoring.yaml
- helmrelease-cert-utils-operator.yaml
- helmrelease-kyverno.yaml
- helmrelease-trivy-operator-polr-adapter.yaml
- cri-o-garbage-collector.yaml

patchesStrategicMerge: []

patches: []
#- target:
#    kind: Deployment
#    name: example
#    namespace: my-app
#  patch: |-
#    - op: add
#      path: /spec/template/spec/hostNetwork
#      value: true
#    - op: replace
#      path: /spec/template/spec/containers/0/args/3
#      value: "--some-param"
#    - op: add
#      path: /spec/template/spec/containers/0/env/-
#      value:
#        name: AWS_REGION
#        value: "us-east-1"
