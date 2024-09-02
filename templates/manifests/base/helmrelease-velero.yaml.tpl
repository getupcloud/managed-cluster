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
      version: "~> 2.32"
  install:
    createNamespace: true
    disableWait: false
    remediation:
      retries: -1
  upgrade:
    disableWait: false
    remediation:
      retries: -1
  interval: 5m
  storageNamespace: velero
  targetNamespace: velero
  releaseName: velero
  values:
    configuration:
      backupStorageLocation:
        name: default

      volumeSnapshotLocation:
        name: default

    credentials:
      useSecret: true
      secretContents:
        cloud: ""

    tolerations:
    - key: dedicated
      value: infra
      effect: NoSchedule

    affinity:
      nodeAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          preference:
            matchExpressions:
            - key: node-role.kubernetes.io/infra
              operator: Exists
        - weight: 90
          preference:
            matchExpressions:
            - key: role
              operator: In
              values:
              - infra

    resources:
      requests:
        memory: 256Mi
        cpu: 100m
      limits:
        memory: 1Gi
        cpu: 500m

    metrics:
      enabled: true
      serviceMonitor:
        enabled: true
      prometheusRule:
        enabled: true
        spec:
        - alert: VeleroBackupPartialFailures
          expr: velero_backup_partial_failure_total{schedule!=""} / velero_backup_attempt_total{schedule!=""} > 0.25
          for: 15m
          labels:
            service: backup
            severity: warning
          annotations:
            message: "Velero backup {{ $labels.schedule }} has {{ $value | humanizePercentage }} partialy failed backups."
            summary: "Some backups have partialy failed"

        - alert: VeleroBackupFailures
          expr: velero_backup_failure_total{schedule!=""} / velero_backup_attempt_total{schedule!=""} > 0.25
          for: 15m
          labels:
            service: backup
            severity: warning
          annotations:
            message: "Velero backup {{ $labels.schedule }} has {{ $value | humanizePercentage }} failed backups."
            summary: "Some backups have failed"

        - alert: VeleroBackupPartialFailures
          expr: sum(rate(velero_backup_partial_failure_total{schedule!=""}[24h])) > 0
          for: 10m
          labels:
            service: backup
            severity: critical
          annotations:
            message: "Velero backup {{ $labels.schedule }} has {{ $value }} partialy failed backups."
            summary: "Some backups have partialy failed"

        - alert: VeleroBackupFailures
          expr: sum(rate(velero_backup_failure_total{schedule!=""}[24h])) > 0
          for: 10m
          labels:
            service: backup
            severity: critical
          annotations:
            message: "Velero backup {{ $labels.schedule }} has {{ $value }} failed backups."
            summary: "Some backups have failed"

        - alert: BackupNotActive
          expr: absent(kube_pod_container_status_ready{namespace="velero"} == 1)
          for: 10m
          labels:
            service: backup
            severity: critical
          annotations:
            message: "Velero is not installed or has stopped."
            summary: "Velero not active"

        - alert: BackupNotConfigured
          expr: sum(rate(velero_backup_total[24h])) == 0
          for: 24h
          labels:
            service: backup
            severity: critical
          annotations:
            message: "Velero has not created any backups in the last 24h. Please check Schedules."
            summary: "No Velero backups found"

    schedules:
      volumes:
        schedule: '0 3 * * *'
        template:
          storageLocation: default
          ttl: 168h0m0s

          # Please note labelSelector can't be empty
          # https://github.com/vmware-tanzu/velero/issues/2083
          #labelSelector:
          #  app: web

          includedResources:
          - persistentvolumeclaims
          - persistentvolumes
          includeClusterResources: true

          snapshotVolumes: true
          volumeSnapshotLocations:
          - default

      resources:
        schedule: '0 */12 * * *'
        template:
          storageLocation: default
          ttl: 720h0m0s

          # Please note labelSelector can't be empty
          # https://github.com/vmware-tanzu/velero/issues/2083
          #labelSelector:
          #  app: web

          includedNamespaces:
          - "*"
          excludedNamespaces:
          - kube-public
          - monitoring
          - velero
          includedResources:
          - "*"
          excludedResources: []
          includeClusterResources: true

          snapshotVolumes: false
%{~ endif }
