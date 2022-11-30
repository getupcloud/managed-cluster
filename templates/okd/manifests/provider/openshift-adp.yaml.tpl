---
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-adp

---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: oadp-operator
  namespace: openshift-adp
spec:
  channel: stable
  installPlanApproval: Automatic
  name: oadp-operator
  source: community-operators
  sourceNamespace: openshift-marketplace
  startingCSV: oadp-operator.v0.5.6

%{ if cluster_provider == "aws" ~}
---
apiVersion: v1
kind: Secret
metadata:
  name: cloud-credentials
  namespace: openshift-adp
data:
  cloud: ${ base64encode(<<EOF
[default]
aws_access_key_id=${ modules.velero.output.config.iam_access_key_id }
aws_secret_access_key=${ modules.velero.output.config.iam_secret_access_key }
EOF
)}
%{~ endif }

---
apiVersion: oadp.openshift.io/v1alpha1
kind: DataProtectionApplication
metadata:
  name: velero
  namespace: openshift-adp
spec:
  configuration:
    velero:
      defaultPlugins:
      - openshift
      - csi
      featureFlags:
      - EnableCSI
      podConfig:
        resourceAllocations:
          limits:
            cpu: "1"
            memory: 1Gi
    restic:
      enable: false
%{~ if cluster_provider == "aws" }
  backupLocations:
  - velero:
      provider: aws
      default: true
      objectStorage:
        bucket: ${ modules.velero.output.config.bucket_name }
        prefix: velero
      config:
        region: ${ modules.velero.output.config.bucket_region }
        profile: default
      credential:
        key: cloud
        name: cloud-credentials
  snapshotLocations:
  - velero:
      provider: aws
      config:
        region: ${ modules.velero.output.config.bucket_region }
        profile: "default"
%{~ endif }

---
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: full-backup
  namespace: openshift-adp
spec:
  schedule: '@every 24h'
  template:
    includeClusterResources: true
    includedNamespaces:
    - '*'
    ttl: 336h0m0s
  useOwnerReferencesInBackup: false
