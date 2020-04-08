resource "azurerm_traffic_manager_profile" "shared_traffic" {
  name                   = "${var.dns_prefix}tfm"
  resource_group_name    = azurerm_resource_group.acrrg.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = "${var.dns_prefix}tfm"
    ttl           = 100
  }

  monitor_config {
    protocol                     = "http"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }

  tags = {
    environment = "shared"
    project     = "phoenix"
  }
}