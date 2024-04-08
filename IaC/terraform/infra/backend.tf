# terraform {
#   backend "azurerm" {
#     storage_account_name = "sebterraformprodsa"
#     container_name       = "statefiles"
#     key                  = "gitops-mqtt-aks/state." #this is the blob name; terraform appends env:<workspace> to the end of the name.
#     use_azuread_auth     = true
#     tenant_id            = ""
#     subscription_id      = ""
#   }
# }