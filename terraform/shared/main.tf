#-----------------------------------
# Get Existing API Management
#-----------------------------------
data "azurerm_api_management" "apim" {
  name                = var.apim_name
  resource_group_name = var.rg_name
}

# Create a product
resource "azurerm_api_management_product" "premiumproduct" {
  product_id          = "premium"
  resource_group_name = var.rg_name
  api_management_name = data.azurerm_api_management.apim.name
  display_name        = "Premium product"
  subscription_required = true
  approval_required     = false
  published             = true

}


# custom policy - product
resource "azurerm_api_management_product_policy" "premiumproductpolicy" { 
  resource_group_name = var.rg_name
  api_management_name = data.azurerm_api_management.apim.name
  product_id          = azurerm_api_management_product.premiumproduct.id
  xml_content         = file("./policies/pdt-premium-policy.xml")
    depends_on = [azurerm_api_management_product.premiumproduct]
 }

resource "azurerm_api_management_group" "group1" {
  name                = "my-group"
  api_management_name = data.azurerm_api_management.apim.name
  resource_group_name = var.rg_name
  display_name        = "My Group"
  description         = "This is an example API management group."
}

resource "azurerm_api_management_product_group" "example" {
  product_id          = azurerm_api_management_product.premiumproduct.product_id
  group_name          = azurerm_api_management_group.group1.name
  api_management_name = data.azurerm_api_management.apim.name
  resource_group_name = var.rg_name
}
# Subscription
resource "azurerm_api_management_subscription" "premium_subscription" {
  resource_group_name = var.rg_name
  api_management_name = data.azurerm_api_management.apim.name
  display_name        = "Premium Subscription"
  primary_key         = "premium-primary-key-${substr(sha1(var.rg_name), 0, 8)}"
  secondary_key       = "premium-secondary-key-${substr(sha1(var.rg_name), 0, 8)}"
  product_id          = azurerm_api_management_product.premiumproduct.id
}
