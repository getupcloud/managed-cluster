%{ if modules.ecr.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: ecr-credentials-sync
  namespace: flux-system
spec:
  chart:
    spec:
      chart: ecr-credentials-sync
      sourceRef:
        kind: HelmRepository
        name: getupcloud
      version: "0.2.2"
  install:
    createNamespace: true
    disableWait: false
    remediation:
      retries: -1
  upgrade:
    remediation:
      retries: -1
  interval: 5m
  releaseName: ecr-credentials-sync
  storageNamespace: flux-system
  targetNamespace: flux-system
  values:
    secret:
      name: ecr-credentials
      namespaceSelector: flux-system
    awsAccountId: "${aws.account_id}"
    ecr:
      region: "${aws.region}" 

    schedule: "0 */6 * * *"

    nodeSelector: {}

    tolerations: []

    affinity: {}

%{~ if modules.ecr.output.iam_role_arn != ""}
    serviceAccount:
      create: true
      name: "ecr-credentials-sync"
      annotations:
        eks.amazonaws.com/role-arn: ${try(modules.ecr.output.iam_role_arn, "")}
%{~ endif }
%{~ endif }
