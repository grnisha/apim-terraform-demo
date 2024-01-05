locals {
  resource_location = lower(replace(var.location, " ", ""))
}

#-------------------------------
# calling the Resource Naming module
#-------------------------------
module "resource_suffix" {
  source                 = "./modules/service-suffix"
  workload_name          = var.workload_name
  deployment_environment = var.deployment_environment
  location               = local.resource_location
  resource_suffix        = var.resource_suffix
}

#-------------------------------
# calling the Shared module
#-------------------------------
module "shared" {
  source                = "./modules/shared"
  resource_suffix       = module.resource_suffix.name
  location              = local.resource_location
}


#-------------------------------
# calling the APIM module
#-------------------------------
module "apim" {
  source              = "./modules/apim"
  resource_suffix     = module.resource_suffix.name
  location            = local.resource_location
  workspace_id        = module.shared.workspace_id
  instrumentation_key = module.shared.instrumentation_key
  apim_subnet_id      = module.networking.apim_subnet_id
}


