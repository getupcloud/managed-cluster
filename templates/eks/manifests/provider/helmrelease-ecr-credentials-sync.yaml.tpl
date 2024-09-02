%{ if modules.ecr.enabled ~}
apiVersion: helm.toolkit.fluxcd.io/v2
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
      version: "~> 2"
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
      ## Use empty object {} to copy secret.name to all namespaces
      #namespaceLabelSelector:
      #  app.kubernetes.io/instance: flux-system
    awsAccountId: "${aws.account_id}"
    ecr:
      region: "${aws.region}"

    tolerations:
    - effect: NoSchedule
      operator: Exists

%{~ if modules.ecr.output.iam_role_arn != ""}
    serviceAccount:
      create: true
      name: "ecr-credentials-sync"
      roleArn: ${try(modules.ecr.output.iam_role_arn, "")}
%{~ endif }
%{~ endif }
