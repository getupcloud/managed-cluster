apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: cluster-autoscaler
  namespace: flux-system
spec:
  values:
    autoDiscovery:
      clusterName: ${cluster_name}
    cloudProvider: aws
    awsRegion: us-east-1
    rbac:
      serviceAccount:
        name: cluster-autoscaler
        annotations:
          eks.amazonaws.com/role-arn: ${modules_output.cluster-autoscaler.iam_role_arn}

