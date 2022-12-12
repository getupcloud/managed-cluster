%{ if modules.velero.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: velero
  namespace: flux-system
spec:
  values:
    initContainers:
    - name: velero-plugin-for-aws
      image: velero/velero-plugin-for-aws:v1.3.0
      volumeMounts:
      - mountPath: /target
        name: plugins

    configuration:
      provider: aws

      backupStorageLocation:
        name: default
        prefix: velero/${cluster_name}-${suffix}
        bucket: ${modules.velero.output.bucket_name}
        config:
          region: ${modules.velero.output.bucket_region}

      volumeSnapshotLocation:
        name: default
        config:
          region: ${modules.velero.output.bucket_region}

    # Auth via IRSA
    serviceAccount:
      server:
        create: true
        name: velero
        annotations:
          eks.amazonaws.com/role-arn: ${modules.velero.output.iam_role_arn}

#    # Auth via accesskey
#    credentials:
#      useSecret: true
#      secretContents:
#        cloud: |-
#          [default]
#          aws_access_key_id=                       ### TODO: UPDATE HERE ###
#          aws_secret_access_key=                   ### TODO: UPDATE HERE ###
#          aws_region=                              ### TODO: UPDATE HERE ###
%{~ endif }
