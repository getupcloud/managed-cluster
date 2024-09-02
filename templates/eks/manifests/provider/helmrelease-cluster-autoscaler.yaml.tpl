apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: cluster-autoscaler
  namespace: flux-system
spec:
  values:
    image:
      tag: v${kubernetes_version}.0
    autoDiscovery:
      clusterName: ${cluster_name}
    cloudProvider: aws
    awsRegion: ${aws.region}
    extraArgs:
      balance-similar-node-groups: true
      skip-nodes-with-system-pods: true
    rbac:
      serviceAccount:
        name: cluster-autoscaler
        annotations:
          eks.amazonaws.com/role-arn: ${modules.cluster-autoscaler.output.iam_role_arn}
