%{ if modules.trivy.enabled ~}
%{ if cluster_type == "okd" ~}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: scc:trivy-operator-polr-adapter
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:openshift:scc:privileged
subjects:
- kind: ServiceAccount
  name: trivy-operator-polr-adapter
  namespace: trivy-system
%{~ endif }
%{~ endif }
