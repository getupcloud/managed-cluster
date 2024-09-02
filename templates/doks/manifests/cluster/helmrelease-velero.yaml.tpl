%{ if modules.velero.enabled ~}
## See https://github.com/digitalocean/velero-plugin for instructions
---
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: velero
  namespace: flux-system
spec:
  values:
    initContainers:
    - name: velero-plugin-for-aws
      image: velero/velero-plugin-for-aws:v1.2.0
      volumeMounts:
      - mountPath: /target
        name: plugins
    - name: velero-plugin-for-do
      image: digitalocean/velero-plugin:v1.0.0
      volumeMounts:
      - mountPath: /target
        name: plugins

    configuration:
      provider: aws

      backupStorageLocation:
        prefix: velero/
        bucket: ### TODO: UPDATE HERE ###
        config:
          s3Url: ### TODO: UPDATE HERE ###
          region: ### TODO: UPDATE HERE ###

      volumeSnapshotLocation:
        provider: digitalocean.com/velero
        config:
          region: ### TODO: UPDATE HERE ###

    credentials:
      useSecret: true
      secretContents:
        cloud: |-
          [default]
          aws_access_key_id= ### TODO: UPDATE HERE ###
          aws_secret_access_key= ### TODO: UPDATE HERE ###
          aws_region= ### TODO: UPDATE HERE ###
%{~ endif }
