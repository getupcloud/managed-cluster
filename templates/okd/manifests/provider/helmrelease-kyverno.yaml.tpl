%{ if modules.kyverno.enabled ~}
%{ if cluster_type == "okd" ~}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: scc:kyverno
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:openshift:scc:privileged
subjects:
- kind: ServiceAccount
  name: kyverno
  namespace: kyverno
- kind: ServiceAccount
  name: policy-reporter
  namespace: kyverno
- kind: ServiceAccount
  name: policy-reporter-kyverno-plugin
  namespace: kyverno
%{~ endif }
%{~ endif }
