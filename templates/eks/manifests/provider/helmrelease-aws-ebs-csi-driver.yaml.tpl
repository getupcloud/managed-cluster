apiVersion: helm.toolkit.fluxcd.io/v2beta1
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
      version: 2.11.1
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
          eks.amazonaws.com/role-arn: ${try(modules_output.ebs_csi.iam_role_arn, "")}

      nodeSelector:
        role: infra

      tolerations:
      - key: dedicated
        value: infra
        operator: Equal
        effect: NoSchedule

      limits:
        cpu: 100m
        memory: 128Mi

      requests:
        cpu: 100m
        memory: 128Mi

    storageClasses:
    - name: gp2-csi
      parameters:
        encrypted: "true"
        type: gp2
    - name: gp3-csi
      parameters:
        encrypted: "true"
        type: gp3
      annotations:
        storageclass.kubernetes.io/is-default-class: "true"
