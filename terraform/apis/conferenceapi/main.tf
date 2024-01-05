

#-----------------------------------
# Deploy API
#-----------------------------------
resource "azurerm_api_management_api" "conferenceapi" {
  name                = "conference-api"
  resource_group_name =  var.rg_name
  api_management_name = var.apim_name
  revision            = "1"
  display_name        = "Conference API"
  path                = "conference-api"
  protocols           = ["https"]

  import {
    content_format = "swagger-json"
    content_value  = file("./swagger.json")
  }
}

#-----------------------------------
# Deploy API Policy
#-----------------------------------
resource "azurerm_api_management_api_policy" "conferenceapi" {
  api_management_name = var.apim_name
  resource_group_name = var.rg_name
  api_name            = azurerm_api_management_api.conferenceapi.name
  display_name        = "Conference API Policy"
  xml_content         = file("./policies/api-policy.xml")
  depends_on = [azurerm_api_management_api.conferenceapi]
}

#-----------------------------------
# Get deployed operation GetSessions
#-----------------------------------
data "azurerm_api_management_api_operation" "conferenceapi" {
  api_management_name = var.apim_name
  resource_group_name = var.rg_name
  api_name            = azurerm_api_management_api.conferenceapi.name
  operation_id        = "GetSessions"
}

#-----------------------------------
# Deploy operation policy
#-----------------------------------
resource "azurerm_api_management_api_operation_policy" "conferenceapi" {
  api_management_name = var.apim_name
  resource_group_name = var.rg_name
  api_name            = azurerm_api_management_api.conferenceapi.name
  operation_id        = data.azurerm_api_management_api_operation.conferenceapi.id
  display_name        = "GetSessions Policy"
  xml_content         = file("./policies/operation-policy.xml")
  depends_on = [azurerm_api_management_api_operation.conferenceapi]
}