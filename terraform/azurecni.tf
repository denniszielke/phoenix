# Configure the Azure Provider
# https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/terraform/terraform-create-k8s-cluster-with-tf-and-aks.md

provider "azurerm" {
    subscription_id = var.subscription_id
    # client_id       = var.terraform_client_id
    # client_secret   = var.terraform_client_secret
    tenant_id       = var.tenant_id
    features {}
}

# random value
resource "random_integer" "random_int" {
  min = 10
  max = 99
}

# https://www.terraform.io/docs/providers/azurerm/d/resource_group.html
resource "azurerm_resource_group" "aksrg" {
  name     = "${var.resource_group_name}-${random_integer.random_int.result}"
  location = var.location
    
  tags = {
    Environment = var.environment
  }
}

# https://www.terraform.io/docs/providers/azurerm/d/virtual_network.html
resource "azurerm_virtual_network" "kubevnet" {
  name                = "${var.dns_prefix}-${random_integer.random_int.result}-vnet"
  address_space       = ["10.0.0.0/20"]
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name

  tags = {
    Environment = var.environment
  }
}

# https://www.terraform.io/docs/providers/azurerm/d/subnet.html
resource "azurerm_subnet" "gwnet" {
  name                      = "gw-1-subnet"
  resource_group_name       = azurerm_resource_group.aksrg.name
  #network_security_group_id = "${azurerm_network_security_group.aksnsg.id}"
  address_prefix            = "10.0.1.0/24"
  virtual_network_name      = azurerm_virtual_network.kubevnet.name
}
resource "azurerm_subnet" "acinet" {
  name                      = "aci-2-subnet"
  resource_group_name       = azurerm_resource_group.aksrg.name
  #network_security_group_id = "${azurerm_network_security_group.aksnsg.id}"
  address_prefix            = "10.0.2.0/24"
  virtual_network_name      = azurerm_virtual_network.kubevnet.name
}
resource "azurerm_subnet" "fwnet" {
  name                      = "AzureFirewallSubnet"
  resource_group_name       = azurerm_resource_group.aksrg.name
  #network_security_group_id = "${azurerm_network_security_group.aksnsg.id}"
  address_prefix            = "10.0.6.0/24"
  virtual_network_name      = azurerm_virtual_network.kubevnet.name
}
resource "azurerm_subnet" "ingnet" {
  name                      = "ing-4-subnet"
  resource_group_name       = azurerm_resource_group.aksrg.name
  #network_security_group_id = "${azurerm_network_security_group.aksnsg.id}"
  address_prefix            = "10.0.4.0/24"
  virtual_network_name      = azurerm_virtual_network.kubevnet.name
}
resource "azurerm_subnet" "aksnet" {
  name                      = "aks-5-subnet"
  resource_group_name       = azurerm_resource_group.aksrg.name
  #network_security_group_id = "${azurerm_network_security_group.aksnsg.id}"
  address_prefix            = "10.0.5.0/24"
  virtual_network_name      = azurerm_virtual_network.kubevnet.name
}

#https://www.terraform.io/docs/providers/azurerm/r/application_insights.html
resource "azurerm_application_insights" "aksainsights" {
  name                = "${var.dns_prefix}-${random_integer.random_int.result}-ai"
  application_type    = "Node.JS"
  location            = "West Europe"
  resource_group_name = azurerm_resource_group.aksrg.name
}

# https://www.terraform.io/docs/providers/azurerm/r/redis_cache.html
resource "azurerm_redis_cache" "aksredis" {
  name                = "${var.dns_prefix}-${random_integer.random_int.result}-redis"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  capacity            = 0
  family              = "C"
  sku_name            = "Basic"
  enable_non_ssl_port = true
  redis_configuration {
  }
}

# https://www.terraform.io/docs/providers/azurerm/r/key_vault.html
resource "azurerm_key_vault" "aksvault" {
  name                        = "${var.dns_prefix}-${random_integer.random_int.result}-vault"
  location                    = azurerm_resource_group.aksrg.location
  resource_group_name         = azurerm_resource_group.aksrg.name
  enabled_for_disk_encryption = false
  tenant_id                   = var.tenant_id

  sku_name = "standard"

  access_policy {
    tenant_id = var.tenant_id
    object_id = var.client_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
    ]
  }

  tags = {
    Environment = var.environment
  }
}

# https://www.terraform.io/docs/providers/azurerm/r/key_vault_secret.html
resource "azurerm_key_vault_secret" "appinsights_secret" {
  name         = "phoenix-appinsights-key"
  value        = azurerm_application_insights.aksainsights.instrumentation_key
  key_vault_id = azurerm_key_vault.aksvault.id
  
  tags = {
    source      = "terraform"
    Environment = var.environment
  }
}

resource "azurerm_key_vault_secret" "redis_host_secret" {
  name         = "phoenix-redis-host"
  value        = azurerm_redis_cache.aksredis.hostname
  key_vault_id = azurerm_key_vault.aksvault.id
  
  tags = {
    source      = "terraform"
    Environment = var.environment
  }
}

resource "azurerm_key_vault_secret" "redis_access_secret" {
  name         = "phoenix-redis-access"
  value        = azurerm_redis_cache.aksredis.primary_access_key
  key_vault_id = azurerm_key_vault.aksvault.id
  
  tags = {
    source      = "terraform"
    Environment = var.environment
  }
}

resource "azurerm_key_vault_secret" "acrname_secret" {
  name         = "phoenix-acr-name"
  value        = azurerm_container_registry.aksacr.name
  key_vault_id = azurerm_key_vault.aksvault.id
  
  tags = {
    source      = "terraform"
    Environment = var.environment
  }
}

resource "azurerm_key_vault_secret" "public_ip" {
  name         = "phoenix-ip"
  value        = azurerm_public_ip.nginx_ingress.fqdn
  key_vault_id = azurerm_key_vault.aksvault.id
  
  tags = {
    source      = "terraform"
    Environment = var.environment
  }
}

resource "azurerm_key_vault_secret" "public_ip_stage" {
  name         = "phoenix-ip-stage"
  value        = azurerm_public_ip.nginx_ingress-stage.fqdn
  key_vault_id = azurerm_key_vault.aksvault.id
  
  tags = {
    source      = "terraform"
    Environment = var.environment
  }
}

# https://www.terraform.io/docs/providers/azurerm/d/log_analytics_workspace.html
resource "azurerm_log_analytics_workspace" "akslogs" {
  name                = "${var.dns_prefix}-${random_integer.random_int.result}-lga"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "akslogs" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.aksrg.location
  resource_group_name   = azurerm_resource_group.aksrg.name
  workspace_resource_id = azurerm_log_analytics_workspace.akslogs.id
  workspace_name        = azurerm_log_analytics_workspace.akslogs.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

# https://www.terraform.io/docs/providers/azurerm/d/kubernetes_cluster.html
resource "azurerm_kubernetes_cluster" "akstf" {
  name                = "${var.dns_prefix}-${random_integer.random_int.result}"
  location            = azurerm_resource_group.aksrg.location
  resource_group_name = azurerm_resource_group.aksrg.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  node_resource_group = "${azurerm_resource_group.aksrg.name}_nodes_${azurerm_resource_group.aksrg.location}"
  linux_profile {
    admin_username = "phoenix"

    ssh_key {
      key_data = file("${var.ssh_public_key}")
    }
  }

  default_node_pool {
    name               = "default"
    node_count         = 1
    vm_size            = "Standard_DS2_v2" #"Standard_F4s" # Standard_DS2_v2
    os_disk_size_gb    = 120
    max_pods           = 30
    vnet_subnet_id     = azurerm_subnet.aksnet.id
    type               = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    min_count       = 1
    max_count       = 4
  }

  network_profile {
      network_plugin = "azure"
      service_cidr   = "10.2.0.0/24"
      dns_service_ip = "10.2.0.10"
      docker_bridge_cidr = "172.17.0.1/16"
      #pod_cidr = "" selected by subnet_id
      load_balancer_sku = "standard"
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.akslogs.id
    }

    kube_dashboard {
      enabled = true
    }
  }

  tags = {
    Environment = var.environment
  }
}

# # https://www.terraform.io/docs/providers/azurerm/r/role_assignment.html
resource "azurerm_role_assignment" "aksacrrole" {
  scope                = azurerm_container_registry.aksacr.id
  role_definition_name = "Reader"
  principal_id         = var.client_id
  
  depends_on = [azurerm_container_registry.aksacr]
}

# https://www.terraform.io/docs/providers/azurerm/r/container_registry.html

resource "azurerm_container_registry" "aksacr" {
  name                     = "${var.dns_prefix}-${random_integer.random_int.result}-acr"
  resource_group_name      = azurerm_resource_group.aksrg.name
  location                 = azurerm_resource_group.aksrg.location
  sku                      = "Standard"
  admin_enabled            = true
}

# Create Static Public IP Address to be used by Nginx Ingress
resource "azurerm_public_ip" "nginx_ingress" {
  name                         = "nginx-ingress-pip"
  location                     = azurerm_kubernetes_cluster.akstf.location
  resource_group_name          = azurerm_kubernetes_cluster.akstf.node_resource_group
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${var.dns_prefix}-${random_integer.random_int.result}"

  depends_on = [azurerm_kubernetes_cluster.akstf]
}

resource "azurerm_public_ip" "nginx_ingress-stage" {
  name                         = "nginx-ingress-pip-stage"
  location                     = azurerm_kubernetes_cluster.akstf.location
  resource_group_name          = azurerm_kubernetes_cluster.akstf.node_resource_group
  allocation_method            = "Static"
  sku                          = "Standard"
  domain_name_label            = "${var.dns_prefix}-${random_integer.random_int.result}-stage"

  depends_on = [azurerm_kubernetes_cluster.akstf]
}

resource "kubernetes_namespace" "nginx-ns" {
  metadata {
    name = "nginx"
  }

  depends_on = [azurerm_kubernetes_cluster.akstf]
}

# Install Nginx Ingress using Helm Chart
# https://www.terraform.io/docs/providers/helm/release.html
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = data.helm_repository.stable.metadata.0.name
  chart      = "nginx-ingress"
  namespace  = "nginx"
  force_update = "true"
  timeout = "500"

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = azurerm_public_ip.nginx_ingress.ip_address
  }
  
  set {
    name  = "controller.replicaCount"
    value = "2"
  }

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.stats.enabled"
    value = "true"
  }

  depends_on = [azurerm_kubernetes_cluster.akstf, kubernetes_namespace.nginx-ns, azurerm_public_ip.nginx_ingress]
}

# merge kubeconfig from the cluster
resource "null_resource" "get-credentials" {
  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${azurerm_resource_group.aksrg.name} --name ${azurerm_kubernetes_cluster.akstf.name}"
  }
  depends_on = [azurerm_kubernetes_cluster.akstf]
}

# set env variables for scripts
resource "null_resource" "set-env-vars" {
  provisioner "local-exec" {
    command = "export KUBE_GROUP=${azurerm_resource_group.aksrg.name}; export KUBE_NAME=${azurerm_kubernetes_cluster.akstf.name}; export LOCATION=${var.location}"
  }
  depends_on = [azurerm_kubernetes_cluster.akstf]
}

output "NODE_GROUP" {
  value = "${azurerm_resource_group.aksrg.name}_nodes_${azurerm_resource_group.aksrg.location}"
}

output "ID" {
    value = azurerm_kubernetes_cluster.akstf.id
}

output "PUBLIC_IP" {
    value = azurerm_public_ip.nginx_ingress.fqdn
}

output "PUBLIC_IP_STAGE" {
    value = azurerm_public_ip.nginx_ingress-stage.fqdn
}

output "instrumentation_key" {
  value = azurerm_application_insights.aksainsights.instrumentation_key
}