#-------------------------------
# Common variables
#-------------------------------
variable "resource_suffix" {
  type = string
}

variable "location" {
  description = "The location of the apim instance"
  type        = string
}

variable "key_vault_sku" {
  type        = string
  description = "The Name of the SKU used for this Key Vault. Possible values are standard and premium"
  default     = "standard"
}
