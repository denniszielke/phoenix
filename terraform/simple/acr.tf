# Configure the Azure Provider
# https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/terraform/terraform-create-k8s-cluster-with-tf-and-aks.md
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.18.0"
    }
  }
}
provider "azurerm" {
    subscription_id = var.subscription_id
    #client_id       = var.terraform_serviceprincipal_id
    #client_secret   = var.terraform_serviceprincipal_secret
    tenant_id       = var.tenant_id
    environment     = "public"
    features {}
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
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.akstf.kubelet_identity[0].object_id
  
  depends_on = [azurerm_container_registry.aksacr, azurerm_kubernetes_cluster.akstf]
}

resource "azurerm_role_assignment" "azdoacrrole" {
  scope                = azurerm_container_registry.aksacr.id
  role_definition_name = "AcrPush"
  principal_id         = var.azdo_service_principal_objectid
  
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