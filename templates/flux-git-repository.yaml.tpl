---
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: ${ name }
  namespace: ${ namespace }
spec:
  interval: ${ reconcile_interval }
  url: ${ git_repo }
  ref:
    branch: main
  secretRef:
    name: ${ name }-ssh-credentials
---
apiVersion: v1
kind: Secret
metadata:
  name: ${ name }-ssh-credentials
  namespace: ${ namespace }
type: Opaque
data:
  identity: ${ base64encode(identity) }
  identity.pub: ${ base64encode(identity_pub) }
  known_hosts: ${ base64encode(known_hosts) }
---
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
kind: Kustomization
metadata:
  name: ${ name }
  namespace: ${ namespace }
spec:
  interval: ${ reconcile_interval }
  path: ${ manifests_path }
  prune: true
  sourceRef:
    kind: GitRepository
    name: ${ name }
