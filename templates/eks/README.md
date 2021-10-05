# Create VPC using CloudFormation

See ./cloudformation for templates.

# VPC requirements

- At least 2 subnets (for HA)
- All subnets with `Auto-assign IPv4 = on`
- All subnets with `DNS hostnames = on`
- Internet Gateway attached to VPC
- Route Table for all subnets with default gateway (0.0.0.0/0) routing to Internet Gateway


# Required IAM permissions

##################################################
### Remember to fill ${var.cluster_name} below ###
##################################################

```hcl
data "aws_caller_identity" "current" {}

resource "aws_iam_user_policy_attachment" "cluster-user-attach" {
  user       = data.aws_caller_identity.current.user_id
  policy_arn = aws_iam_policy.cluster.arn
}

resource "aws_iam_policy" "cluster" {
    name   = "eks-${var.cluster_name}"
    path   = "/"
    policy = <<POLICY
{
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "EksBasePolicy",
                    "Effect": "Allow",
                    "Action": [
                        "eks:DeleteFargateProfile",
                        "ec2:CreateDhcpOptions",
                        "ec2:AuthorizeSecurityGroupIngress",
                        "eks:DescribeFargateProfile",
                        "iam:List*",
                        "ec2:AttachInternetGateway",
                        "iam:PutRolePolicy",
                        "iam:AddRoleToInstanceProfile",
                        "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
                        "ec2:DeleteRouteTable",
                        "ec2:DeleteVpnGateway",
                        "ec2:RevokeSecurityGroupEgress",
                        "ec2:CreateRoute",
                        "ec2:CreateInternetGateway",
                        "ec2:DeleteInternetGateway",
                        "iam:DeleteOpenIDConnectProvider",
                        "ec2:Associate*",
                        "autoscaling:DeleteTags",
                        "iam:GetRole",
                        "iam:GetPolicy",
                        "ec2:CreateTags",
                        "ec2:RunInstances",
                        "iam:DeleteRole",
                        "ec2:AssignPrivateIpAddresses",
                        "ec2:CreateVolume",
                        "eks:CreateFargateProfile",
                        "ec2:RevokeSecurityGroupIngress",
                        "ec2:CreateNetworkInterface",
                        "autoscaling:AttachInstances",
                        "ec2:DeleteDhcpOptions",
                        "eks:UpdateNodegroupConfig",
                        "ec2:DeleteNatGateway",
                        "eks:ListClusters",
                        "autoscaling:DeleteAutoScalingGroup",
                        "ec2:CreateSubnet",
                        "iam:GetOpenIDConnectProvider",
                        "iam:GetRolePolicy",
                        "ec2:ModifyVpcEndpoint",
                        "autoscaling:DetachInstances",
                        "iam:CreateInstanceProfile",
                        "iam:UntagRole",
                        "ec2:CreateNatGateway",
                        "iam:TagRole",
                        "ec2:CreateVpc",
                        "ec2:ModifySubnetAttribute",
                        "ec2:CreateDefaultSubnet",
                        "iam:DeleteRolePolicy",
                        "ec2:DeleteLaunchTemplateVersions",
                        "eks:CreateCluster",
                        "ec2:ReleaseAddress",
                        "iam:DeleteInstanceProfile",
                        "ec2:DeleteLaunchTemplate",
                        "eks:UntagResource",
                        "iam:CreatePolicy",
                        "autoscaling:CreateLaunchConfiguration",
                        "ec2:Describe*",
                        "ec2:CreateLaunchTemplate",
                        "ec2:Disassociate*",
                        "eks:TagResource",
                        "iam:UpdateAssumeRolePolicy",
                        "iam:GetPolicyVersion",
                        "ec2:DeleteSubnet",
                        "eks:ListTagsForResource",
                        "iam:RemoveRoleFromInstanceProfile",
                        "iam:CreateRole",
                        "eks:UpdateClusterConfig",
                        "iam:AttachRolePolicy",
                        "ec2:DeleteVolume",
                        "eks:DescribeNodegroup",
                        "ec2:GetLaunchTemplateData",
                        "iam:DetachRolePolicy",
                        "autoscaling:UpdateAutoScalingGroup",
                        "ec2:DetachVolume",
                        "eks:ListNodegroups",
                        "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
                        "autoscaling:SetDesiredCapacity",
                        "ec2:CreateRouteTable",
                        "ec2:DeleteNetworkInterface",
                        "autoscaling:SuspendProcesses",
                        "ec2:DetachInternetGateway",
                        "eks:DeleteCluster",
                        "eks:DeleteNodegroup",
                        "autoscaling:CreateOrUpdateTags",
                        "eks:DescribeCluster",
                        "iam:DeleteServiceLinkedRole",
                        "ec2:DeleteVpc",
                        "ec2:CreateEgressOnlyInternetGateway",
                        "autoscaling:CreateAutoScalingGroup",
                        "eks:UpdateClusterVersion",
                        "autoscaling:Describe*",
                        "ec2:DeleteTags",
                        "iam:DeletePolicy",
                        "eks:UpdateNodegroupVersion",
                        "ec2:CreateSecurityGroup",
                        "ec2:ModifyVpcAttribute",
                        "iam:CreatePolicyVersion",
                        "ec2:AuthorizeSecurityGroupEgress",
                        "ec2:DeleteEgressOnlyInternetGateway",
                        "ec2:DetachNetworkInterface",
                        "iam:GetInstanceProfile",
                        "ec2:DeleteRoute",
                        "eks:CreateNodegroup",
                        "ec2:AllocateAddress",
                        "ec2:CreateLaunchTemplateVersion",
                        "iam:CreateOpenIDConnectProvider",
                        "eks:ListFargateProfiles",
                        "autoscaling:DeleteLaunchConfiguration",
                        "eks:DescribeUpdate",
                        "ec2:DeleteSecurityGroup",
                        "ec2:ModifyLaunchTemplate",
                        "ec2:AttachNetworkInterface"
                    ],
                    "Resource": "*"
                },
                {
                    "Sid": "EksRestrictedPolicy",
                    "Effect": "Allow",
                    "Action": [
                        "iam:PassRole",
                        "iam:CreateServiceLinkedRole"
                    ],
                    "Resource": [
                        "arn:aws:iam::XXXXXXXXXXXX:user/eks-admin-${var.cluster_name}"
                    ]
                },
                {
                    "Sid": "EksExtraPolicy",
                    "Effect": "Allow",
                    "Action": [
                        "iam:DeleteAccessKey",
                        "iam:GetUserPolicy",
                        "iam:DeleteUserPolicy",
                        "iam:DeleteUser",
                        "iam:GetUser",
                        "iam:CreateUser",
                        "iam:CreateAccessKey",
                        "iam:PutUserPolicy",
                        "route53:AssociateVPCWithHostedZone"
                    ],
                    "Resource": [
                        "arn:aws:iam::XXXXXXXXXXXX:user/${var.cluster_name}-velero-backup-*",
                        "arn:aws:iam::XXXXXXXXXXXX:user/${aws:username}"
                    ]
                },
                {
                    "Sid": "EksS3Policy",
                    "Effect": "Allow",
                    "Action": "s3:*",
                    "Resource": "arn:aws:s3:::${var.cluster_name}-velero-backup-*"
                }
            ]
}
POLICY
}
```
