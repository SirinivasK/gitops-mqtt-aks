resource "azurerm_resource_group" "this" {
  name     = "${local.service_name}-${terraform.workspace}-${local.location_short}-rg"
  location = "${local.location}"
}


resource "azurerm_kubernetes_cluster" "this" {
  name                = "${local.service_name}-${terraform.workspace}-${local.location_short}-aks"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = "${local.service_name}-${terraform.workspace}-${local.location_short}-dns"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}


# resource "azurerm_log_analytics_workspace" "this" {
#   name                = "${local.service_name}-${terraform.workspace}-${local.location_short}-la"
#   location            = azurerm_resource_group.this.location
#   resource_group_name = azurerm_resource_group.this.name
#   sku                 = "PerGB2018"
# }
