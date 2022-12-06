%{ if secret_manager.name == "kms" ~}
%{ if secret_manager.config != null && secret_manager.config.enabled ~}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kustomize-controller
  namespace: ${ namespace }
  annotations:
    eks.amazonaws.com/role-arn: ${ secret_manager.config.output.iam_role_arn }
    kms-key-id: ${ secret_manager.config.output.key_id }
%{~ endif }
%{~ endif }
