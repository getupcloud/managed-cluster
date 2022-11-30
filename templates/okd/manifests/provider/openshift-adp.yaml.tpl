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
  name: velero-cloud-credentials
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
    restic:
      enable: true
%{~ if cluster_provider == "aws" }
  backupLocations:
    - name: default
      velero:
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
          name: velero-cloud-credentials
  snapshotLocations:
    - name: default
      velero:
        provider: aws
        config:
          region: ${ modules.velero.output.config.bucket_region }
          profile: "default"
%{~ endif }
