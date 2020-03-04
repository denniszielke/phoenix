# Configure the Azure Provider
# https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/terraform/terraform-create-k8s-cluster-with-tf-and-aks.md

provider "azurerm" {
    subscription_id = var.subscription_id
    #client_id       = var.terraform_client_id
    #client_secret   = var.terraform_client_secret
    tenant_id       = var.tenant_id
    features {}
}

# https://www.terraform.io/docs/providers/azurerm/d/client_config.html
data "azurerm_client_config" "current" {
}

# random value
resource "random_integer" "random_int" {
  min = 100
  max = 999
}

# https://www.terraform.io/docs/providers/azurerm/d/resource_group.html
resource "azurerm_resource_group" "acrrg" {
  name     = var.resource_group_name
  location = var.location
    
  tags = {
    environment = "shared"
    project     = "phoenix"
  }
}

# https://www.terraform.io/docs/providers/azurerm/r/role_assignment.html
resource "azurerm_role_assignment" "aksacrrole" {
  scope                = azurerm_container_registry.aksacr.id
  role_definition_name = "Reader"
  principal_id         = var.client_objectid
  
  depends_on = [azurerm_container_registry.aksacr]
}

# https://www.terraform.io/docs/providers/azurerm/r/container_registry.html

resource "azurerm_container_registry" "aksacr" {
  name                     = "${var.dns_prefix}acr"
  resource_group_name      = azurerm_resource_group.acrrg.name
  location                 = azurerm_resource_group.acrrg.location
  sku                      = "Standard"
  admin_enabled            = true
}