#-----------------------------------
# Get Existing API Management
#-----------------------------------
data "azurerm_api_management" "apim" {
  name                = var.apim_name
  resource_group_name = var.rg_name
}

#-----------------------------------
# Deploy API
#-----------------------------------
resource "azurerm_api_management_api" "wizardworldapi" {
  name                = "wizardworld-api"
  resource_group_name = var.rg_name
  api_management_name = data.azurerm_api_management.apim.name
  revision            = "1"
  display_name        = "Wizard World API"
  path                = "wizardworld"
  protocols           = ["https"]
  service_url         = "https://wizardworld-api.azurewebsites.net"
}

#-----------------------------------
# Deploy API Policy
#-----------------------------------
resource "azurerm_api_management_api_policy" "wizardworldapi" {
  api_management_name = var.apim_name
  resource_group_name = var.rg_name
  api_name            = azurerm_api_management_api.wizardworldapi.name
  xml_content         = file("./policies/api-policy.xml")
  depends_on = [azurerm_api_management_api.wizardworldapi]
}

#-----------------------------------
# Deploy API Schema
#-----------------------------------
resource "azurerm_api_management_api_schema" "wizardworldapi" {
  api_management_name = var.apim_name
  resource_group_name = var.rg_name
  api_name            = azurerm_api_management_api.wizardworldapi.name
  content_type        = "application/vnd.oai.openapi.components+json"
  document            = file("./schemas/wizardworldapi.json")
  schema_id           = "wizardworldschema"
  depends_on = [azurerm_api_management_api.wizardworldapi]
}


#-----------------------------------
# Deploy API Operation
#-----------------------------------
resource "azurerm_api_management_api_operation" "wizardworldapi" {
  api_management_name = var.apim_name
  resource_group_name = var.rg_name
  api_name            = azurerm_api_management_api.wizardworldapi.name
  name                = "get-elixirs"
  display_name        = "Get Elixirs"
  method              = "GET"
  url_template        = "/Elixirs"
  description         = "Get all Elixirs"
  depends_on = [azurerm_api_management_api.wizardworldapi, azurerm_api_management_api_schema.wizardworldapi]
  request {
    query_parameters {
      name       = "Name"
      type       = "string"
      schema_id  = "wizardworldschema"
      type_name  = "ElixirsGetRequest"
    }
    query_parameters {
      name       = "Difficulty"
      type       = "string"
      values     = ["Unknown", "Advanced", "Moderate", "Beginner", "OrdinaryWizardingLevel", "OneOfAKind"]
      schema_id  = "wizardworldschema"
      type_name  = "ElixirDifficulty"
    }
    query_parameters {
      name       = "Ingredient"
      type       = "string"
      schema_id  = "wizardworldschema"
      type_name  = "ElixirsGetRequest-1"
    }
    query_parameters {
      name       = "InventorFullName"
      type       = "string"
      schema_id  = "wizardworldschema"
      type_name  = "ElixirsGetRequest-2"
    }
    query_parameters {
      name       = "Manufacturer"
      type       = "string"
      schema_id  = "wizardworldschema"
      type_name  = "ElixirsGetRequest-3"
    }
  }

  response {
    status_code = 200
    description = "Success"

    representations {
      content_type = "text/plain"
      schema_id    = "wizardworldschema"
      type_name    = "ElixirsGet200TextPlainResponse"
    }

    representations {
      content_type = "application/json"
      schema_id    = "wizardworldschema"
      type_name    = "ElixirsGet200ApplicationJsonResponse"
    }

    representations {
      content_type = "text/json"
      schema_id    = "wizardworldschema"
      type_name    = "ElixirsGet200TextJsonResponse"
    }
  }
}

#-----------------------------------
# Deploy operation policy
#-----------------------------------
resource "azurerm_api_management_api_operation_policy" "wizardworldapi" {
  api_management_name = var.apim_name
  resource_group_name = var.rg_name
  api_name            = azurerm_api_management_api.wizardworldapi.name
  operation_id        = "get-elixirs"
  xml_content         = file("./policies/op-elixirs-policy.xml")
  depends_on = [azurerm_api_management_api.wizardworldapi]
}