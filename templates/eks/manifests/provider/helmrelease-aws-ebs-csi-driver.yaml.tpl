apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: aws-ebs-csi-driver
  namespace: flux-system
spec:
  chart:
    spec:
      chart: aws-ebs-csi-driver
      sourceRef:
        kind: HelmRepository
        name: aws-ebs-csi-driver
      version: "~> 2.11"
  install:
    createNamespace: true
    disableWait: true
    remediation:
      retries: -1
  upgrade:
    disableWait: true
    remediation:
      retries: -1
  interval: 5m
  releaseName: aws-ebs-csi-driver
  storageNamespace: csi-drivers
  targetNamespace: csi-drivers
  values:
    controller:
      serviceAccount:
        annotations:
          eks.amazonaws.com/role-arn: ${try(modules.ebs-csi.output.iam_role_arn, "")}

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


      tolerations:
      - key: dedicated
        value: infra
        effect: NoSchedule
      - key: CriticalAddonsOnly
        operator: Exists
      - effect: NoExecute
        operator: Exists
        tolerationSeconds: 300

      limits:
        cpu: 100m
        memory: 128Mi

      requests:
        cpu: 100m
        memory: 128Mi

    node:
      tolerateAllTaints: true

    storageClasses:
    - name: gp2-csi
      parameters:
        encrypted: "true"
        type: gp2
      allowVolumeExpansion: "true"
    - name: gp3-csi
      parameters:
        encrypted: "true"
        type: gp3
      annotations:
        storageclass.kubernetes.io/is-default-class: "true"
      allowVolumeExpansion: "true"
