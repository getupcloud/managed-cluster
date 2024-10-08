%{ if modules.velero.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: velero
  namespace: flux-system
spec:
  chart:
    spec:
      chart: velero
      sourceRef:
        kind: HelmRepository
        name: velero
      version: "~> 2.27"
  install:
    createNamespace: true
    disableWait: false
    remediation:
      retries: -1
  interval: 5m
  storageNamespace: velero
  targetNamespace: velero
  values:
    initContainers:
    - name: velero-plugin-for-gcp
      image: velero/velero-plugin-for-gcp:v1.0.0
      volumeMounts:
      - mountPath: /target
        name: plugins

    configuration:
      provider: gcp
      backupStorageLocation:
        name: default
        prefix: velero/${ cluster_id }
        bucket: ${ velero_gcp_bucket }
        config:

      volumeSnapshotLocation:
        name: default
        config:
          project: ${ velero_gcp_project }
          snapshotLocation: ${ velero_gcp_region }

    credentials:
      useSecret: true
      secretContents:
        cloud: |
          ${indent(6, base64decode(velero_gcp_credentials))}

    tolerations:
    - effect: NoSchedule
      key: dedicated
      value: infra
    - effect: NoSchedule
      key: CriticalAddonsOnly

    nodeSelector:
      role: infra

    deployRestic: false

    resources:
      requests:
        memory: 512Mi
        cpu: 50m
      limits:
        memory: 1Gi
        cpu: 100m

    metrics:
      enabled: true
%{~ endif }
