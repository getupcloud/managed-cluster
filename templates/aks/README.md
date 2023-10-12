# Required steps to create a cluster from scratch

## Create a service principal

```sh
az login
az account list
```

Choose `id` for your subscription and run

```sh
ARM_SUBSCRIPTION_ID=<<.id from output above>>

az account set --subscription=${ARM_SUBSCRIPTION_ID}
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/${ARM_SUBSCRIPTION_ID}"
```

Alternativelly, use any of the methods describe in [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure).

## Enable required provider features

```sh
az provider register --namespace Microsoft.OperationalInsights
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.OperationsManagement
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Quota
az provider register --namespace Microsoft.Insights
az rest --verbose --method POST \
    --url https://management.azure.com/subscriptions/${ARM_SUBSCRIPTION_ID}/providers/Microsoft.Features/providers/Microsoft.Compute/features/EncryptionAtHost/register?api-version=2015-12-01
```

## Required resources

### Resource Group

```
AZURE
az account list-locations | jq '.[].name'
AKS_LOCATION=<<select location below>>
AKS_RESOURCE_GROUP_NAME=<<insert resource group name to create>>
az group create --location $AKS_LOCATION --name $AKS_RESOURCE_GROUP_NAME
```

## Network

VNET_NAME=vvnet-name
VNET_CIDR=10.0.0.0/16
SUBNET_NAME=subnet-name
SUBNET_CIDR=10.0.0.0/20

```
az network vnet create -g $AKS_RESOURCE_GROUP_NAME \
    --name $VNET_NAME \
    --address-prefix $VNET_CIDR \
    --subnet-name $SUBNET_NAME \
    --subnet-prefix $SUBNET_CIDR
```

### Quota increase

```
az extension add --name quota
az quota update \
    --resource-name cores \
    --scope /subscriptions/$ARM_SUBSCRIPTION_ID/providers/Microsoft.Compute/locations/eastus/providers/Microsoft.Quota/quotas/cores?api-version=2023-07-01 \
    --limit-object value=10 limit-object-type=LimitValue
```
