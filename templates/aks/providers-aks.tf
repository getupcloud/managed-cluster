provider "azurerm" {
  skip_provider_registration = true
  subscription_id            = var.subscription_id
  tenant_id                  = var.tenant_id
  client_id                  = var.client_id
  client_secret              = var.client_secret

  features {}
}

# Configure the Azure Resource Manager Provider for private DNS zones subscription
provider "azurerm" {
  alias = "private_dns_zone"

  skip_provider_registration = true
  subscription_id            = var.private_dns_zone_subscription_id == "" ? var.subscription_id : var.private_dns_zone_subscription_id
  tenant_id                  = var.tenant_id
  client_id                  = var.client_id
  client_secret              = var.client_secret

  features {}
}

# Configure the Azure Resource Manager Provider for Azure container registry subscription
provider "azurerm" {
  alias = "acr"

  skip_provider_registration = true
  subscription_id            = var.acr_subscription_id == "" ? var.subscription_id : var.acr_subscription_id
  tenant_id                  = var.tenant_id
  client_id                  = var.client_id
  client_secret              = var.client_secret

  features {}
}

provider "azuread" {
  tenant_id = var.tenant_id
  client_id = var.client_id
}
