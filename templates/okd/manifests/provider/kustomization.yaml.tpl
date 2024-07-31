apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
# Do not include all from ../base in order to use openshift native monitoring system
- base-helmrepository.yaml
- base-helmrelease-teleport-agent.yaml
- subscription-cert-manager.yaml
- helmrelease-cert-utils-operator.yaml
- base-helmrelease-x509-exporter.yaml
- helmrepository.yaml
- helmrelease-kyverno.yaml
- helmrelease-trivy-operator-polr-adapter.yaml
- subscription-adp.yaml
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
