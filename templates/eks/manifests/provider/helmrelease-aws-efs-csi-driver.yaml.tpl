%{ if modules.efs.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2
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
      version: "~> 2.2"
  dependsOn: []
  install:
    createNamespace: false
    disableWait: false
    remediation:
      retries: -1
  upgrade:
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
%{~ if modules.efs.output.iam_role_arn != ""}
        annotations:
          eks.amazonaws.com/role-arn: ${modules.efs.output.iam_role_arn}
%{~ endif }
    node:
      serviceAccount:
%{~ if modules.efs.output.iam_role_arn != ""}
        annotations:
          eks.amazonaws.com/role-arn: ${modules.efs.output.iam_role_arn}
%{~ endif }
%{~ if length(try(modules.efs.file_system_id, "")) > 0 }
    storageClasses:
    - name: efs-sc
      annotations:
        # Use that annotation if you want this to your default storageclass
        #storageclass.kubernetes.io/is-default-class: "true"
      mountOptions:
      - tls
      parameters:
        provisioningMode: efs-ap
        fileSystemId: ${modules.efs.file_system_id}
        directoryPerms: "700"
        gidRangeStart: "1000"
        gidRangeEnd: "2000"
        basePath: "/dynamic_provisioning"
      reclaimPolicy: Retain
      volumeBindingMode: Immediate
%{~ endif }
%{~ endif }
