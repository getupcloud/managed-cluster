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
apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
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
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: git
  name: git
  namespace: ${ namespace }
spec:
  replicas: 1
  selector:
    matchLabels:
      app: git
  template:
    metadata:
      labels:
        app: git
    spec:
      containers:
      - image: alpine
        name: git
        command:
        - sh
        - -c
        - |-
          set -e

          echo Installing packages
          apk add git openssh-server openssh-client --no-progress --no-cache

          echo Creating git user
          adduser git -D
          passwd git -d ''
          install -v --mode=700 -d /home/git/.ssh
          install -v --mode=600 /config/authorized_keys /home/git/.ssh/authorized_keys

          echo Setup /git repository
          git init --initial-branch main --shared=world --bare /git
          chmod -R a+w /git
          chown -R git:git /git

          echo Setup sshd
          install -v --mode=600 /config/ssh_host_* /etc/ssh/

          echo Starting sshd
          exec /usr/sbin/sshd -e -D -p 22 \
            -o 'PubkeyAuthentication yes' \
            -o 'PasswordAuthentication yes' \
            -o 'PermitEmptyPasswords yes'

        volumeMounts:
        - name: git
          mountPath: /git
        - name: config
          mountPath: /config
      volumes:
      - name: git
        persistentVolumeClaim:
          claimName: git-data
      - name: config
        configMap:
          name: git-config
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  labels:
    app: git
  name: git-data
  namespace: ${ namespace }
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
  volumeMode: Filesystem
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: git
  name: git
  namespace: ${ namespace }
spec:
  type: NodePort
  ports:
  - nodePort: 32022
    port: 22
    protocol: TCP
    targetPort: 22
  selector:
    app: git
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: git
  name: git-internal
  namespace: ${ namespace }
spec:
  type: ClusterIP
  ports:
  - port: 22
    protocol: TCP
    targetPort: 2222
  selector:
    app: git
---
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app: git
  name: git-config
  namespace: ${ namespace }
data:
  authorized_keys: |-
    ${identity_pub}
  ssh_host_ecdsa_key: |-
    -----BEGIN OPENSSH PRIVATE KEY-----
    b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAaAAAABNlY2RzYS
    1zaGEyLW5pc3RwMjU2AAAACG5pc3RwMjU2AAAAQQRgqr8XGTulVFqvps98mzILFQyW1Rnm
    BdNoQgrJ63aCw/6Wcoo346d1AlZTI9pTISc+ohcIZ0ovMPtxJGBj598LAAAAuN4PgFfeD4
    BXAAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGCqvxcZO6VUWq+m
    z3ybMgsVDJbVGeYF02hCCsnrdoLD/pZyijfjp3UCVlMj2lMhJz6iFwhnSi8w+3EkYGPn3w
    sAAAAhALGvr/TFaFlYgP1B6eK2JirTshVK2YxazS68Jntb2iMdAAAAGHJvb3RAZ2l0LTc3
    ODc0NDRmZi05NGJyaAECAwQFBgc=
    -----END OPENSSH PRIVATE KEY-----
    # required for valid file format
  ssh_host_ecdsa_key.pub: |-
    ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGCqvxcZO6VUWq+mz3ybMgsVDJbVGeYF02hCCsnrdoLD/pZyijfjp3UCVlMj2lMhJz6iFwhnSi8w+3EkYGPn3ws=
  ssh_host_ed25519_key: |-
    -----BEGIN OPENSSH PRIVATE KEY-----
    b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
    QyNTUxOQAAACD/7GBA/13hnkr+TxRQPVxOwy3SJFKYw2A+Fw92u59BnAAAAKAm/tHiJv7R
    4gAAAAtzc2gtZWQyNTUxOQAAACD/7GBA/13hnkr+TxRQPVxOwy3SJFKYw2A+Fw92u59BnA
    AAAEDuyhLvyaqUI53/ZTQN31kuD1ahD5+t0gEyrr3zJ5NIkv/sYED/XeGeSv5PFFA9XE7D
    LdIkUpjDYD4XD3a7n0GcAAAAGHJvb3RAZ2l0LTc3ODc0NDRmZi05NGJyaAECAwQF
    -----END OPENSSH PRIVATE KEY-----
    # required for valid file format
  ssh_host_ed25519_key.pub: |-
    ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP/sYED/XeGeSv5PFFA9XE7DLdIkUpjDYD4XD3a7n0Gc
  ssh_host_rsa_key: |-
    -----BEGIN OPENSSH PRIVATE KEY-----
    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
    -----END OPENSSH PRIVATE KEY-----
    # required for valid file format
  ssh_host_rsa_key.pub: |-
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDinq0LyTjv49feM9fAzTkE5QFCXQWdFBN95QpVrqEPANzgZKuvlwYg/KwjoxYiz0+CTEkedVKNdvwxCvi15B9Ucfnvz0uGS2+CU0M85dSAspGn92EBCFl/gMfXWcxV8PmTokRozQBHsIbzeDeynTBkPHN2rmsywDTptiaa7gZiTTWpiA0xwmJpVPflQllWvboxHh2RYBSHFsVLzteX+FSvSh0b2cRSA0GZovC6KeYUywHft+6/dia7/erbBa5MRgFWXEkUM6R0SDPU/6kKasC8DZiLvGJjCfUP1ycMmLV6rsgAtK/OlIsjz/WuKqlrf1D0KTL9ucsca6RSRJuu7eaNE7/rAN1ZBCO9HScWyTky165biq60hdkK4o5LvfgAs5C7/xzsnks/3pvzfC9Oe++o9BKUI2UT/TQhLc72jqgHy+K5X+bYRAIiHPoB/ASgXr1tmDIGVxhVeIe4oKLe5zJQTGU1Uw45fvsU7A/7OFLplkVdxmoPWQhcVMF3pdUHBXU=
