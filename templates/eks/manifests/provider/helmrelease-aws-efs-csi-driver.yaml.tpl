apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: aws-efs-csi-driver
  namespace: flux-system
spec:
  chart:
    spec:
      chart: aws-efs-csi-driver
      sourceRef:
        kind: HelmRepository
        name: aws-efs-csi-driver
      version: 2.2.0
  dependsOn: []
  install:
    createNamespace: false
    disableWait: false
    remediation:
      retries: -1
  interval: 5m
  releaseName: aws-efs-csi-driver
  storageNamespace: kube-system
  targetNamespace: kube-system
  values:
    controller:
      serviceAccount:
        annotations:
          eks.amazonaws.com/role-arn: ${aws_eks_efs_irsa_arn}
    node:
      serviceAccount:
        annotations:
          eks.amazonaws.com/role-arn: ${aws_eks_efs_irsa_arn}
%{~ if length(aws_eks_efs_storage_class_file_system_id) }
    storageClasses:
    - name: efs-sc
      annotations:
        # Use that annotation if you want this to your default storageclass
        #storageclass.kubernetes.io/is-default-class: "true"
      mountOptions:
      - tls
      parameters:
        provisioningMode: efs-ap
        fileSystemId: fs-05f3047c6163443d9
        directoryPerms: "700"
        gidRangeStart: "1000"
        gidRangeEnd: "2000"
        basePath: "/dynamic_provisioning"
      reclaimPolicy: Delete
      volumeBindingMode: Immediate
%{~ endif }
