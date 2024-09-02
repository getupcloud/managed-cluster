---
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: ${ git_repository_name }
  namespace: ${ namespace }
spec:
  interval: ${ reconcile_interval }
  url: ${ git_repo }
  ref:
    branch: ${ git_branch }
  secretRef:
    name: ${ git_repository_name }
---
apiVersion: v1
kind: Secret
metadata:
  name: ${ git_repository_name }
  namespace: ${ namespace }
type: Opaque
data:
  identity: ${ base64encode(identity) }
  identity.pub: ${ base64encode(identity_pub) }
  known_hosts: ${ base64encode(known_hosts) }
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: ${ git_repository_name }
  namespace: ${ namespace }
spec:
  interval: ${ reconcile_interval }
  path: ${ manifests_path }/cluster
  prune: true
  decryption:
    provider: sops
  sourceRef:
    kind: GitRepository
    name: ${ git_repository_name }
