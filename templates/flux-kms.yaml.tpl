apiVersion: v1
kind: ServiceAccount
metadata:
  name: kustomize-controller
  namespace: ${ namespace }
  annotations:
    eks.amazonaws.com/role-arn: ${ modules.kms.output.iam_role_arn }
