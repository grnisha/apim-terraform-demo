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
  service_url         = "https://wizard-world-api.herokuapp.com"
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
  content_type        = "application/vnd.ms-azure-apim.swagger.definitions+json"
  value               = file("./schemas/wizardworldapi.json")
  schema_id           = "wizardworldschema"
  depends_on = [azurerm_api_management_api.wizardworldapi]
}


#-----------------------------------
# Deploy API Operation - Elixirs
#-----------------------------------
resource "azurerm_api_management_api_operation" "wizardworldapi" {
  api_management_name = var.apim_name
  resource_group_name = var.rg_name
  api_name            = azurerm_api_management_api.wizardworldapi.name
  operation_id        = "get-elixirs"
  display_name        = "Get Elixirs"
  method              = "GET"
  url_template        = "/Elixirs"
  description         = "Get all Elixirs"
  depends_on = [azurerm_api_management_api.wizardworldapi, azurerm_api_management_api_schema.wizardworldapi]
  request {
    query_parameter {
      name       = "Name"
      type       = "string"
      required  = false
    }
    query_parameter {
      name       = "Difficulty"
      type       = "string"
      values     = ["Unknown", "Advanced", "Moderate", "Beginner", "OrdinaryWizardingLevel", "OneOfAKind"]
      schema_id  = "wizardworldschema"
      type_name  = "ElixirDifficulty"
      required  = false
    }
    query_parameter {
      name       = "Ingredient"
      type       = "string"
      required  = false
    }
    query_parameter {
      name       = "InventorFullName"
      type       = "string"
      required  = false
    }
    query_parameter {
      name       = "Manufacturer"
      type       = "string"
      required  = false
    }
  }

  response {
    status_code = 200
    description = "Success"

    representation {
      content_type = "text/plain"
      schema_id    = "wizardworldschema"
      type_name    = "Elixirs"
    }

    representation {
      content_type = "application/json"
      schema_id    = "wizardworldschema"
      type_name    = "Elixirs"
    }

    representation {
      content_type = "text/json"
      schema_id    = "wizardworldschema"
      type_name    = "Elixirs"
    }
  }
}

#-----------------------------------
# Deploy operation policy - Elixirs
#-----------------------------------
resource "azurerm_api_management_api_operation_policy" "wizardworldapi" {
  api_management_name = var.apim_name
  resource_group_name = var.rg_name
  api_name            = azurerm_api_management_api.wizardworldapi.name
  operation_id        = "get-elixirs"
  xml_content         = file("./policies/op-elixirs-policy.xml")
  depends_on = [azurerm_api_management_api.wizardworldapi, azurerm_api_management_api_operation.wizardworldapi]
}

#-----------------------------------
# Deploy API Operation - Houses
#-----------------------------------
resource "azurerm_api_management_api_operation" "wizardworldapihouses" {
  api_management_name = var.apim_name
  resource_group_name = var.rg_name
  api_name            = azurerm_api_management_api.wizardworldapi.name
  operation_id        = "get-houses"
  display_name        = "Get Houses"
  method              = "GET"
  url_template        = "/Houses"
  description         = "Get all Houses"
  depends_on = [azurerm_api_management_api.wizardworldapi, azurerm_api_management_api_schema.wizardworldapi]
  request {
    query_parameter {
      name       = "query"
      type       = "object"
      schema_id  = "wizardworldschema"
      type_name  = "GetHousesQuery"
      required  = false
    }
  }

  response {
    status_code = 200
    description = "Success"

    representation {
      content_type = "text/plain"
      schema_id    = "wizardworldschema"
      type_name    = "Houses"
    }

    representation {
      content_type = "application/json"
      schema_id    = "wizardworldschema"
      type_name    = "Houses"
    }

    representation {
      content_type = "text/json"
      schema_id    = "wizardworldschema"
      type_name    = "Houses"
    }
  }
}

#-----------------------------------
# Get product
#-----------------------------------
data "azurerm_api_management_product" "premiumproduct" {
  product_id          = "premium"
  api_management_name = var.apim_name
  resource_group_name = var.rg_name
}

#-----------------------------------
# Add API to product
#-----------------------------------
resource "azurerm_api_management_product_api" "premiumproduct" {
  api_name            = azurerm_api_management_api.wizardworldapi.name
  product_id          = data.azurerm_api_management_product.premiumproduct.product_id
  api_management_name = var.apim_name
  resource_group_name = var.rg_name
  depends_on = [azurerm_api_management_api.wizardworldapi]
}