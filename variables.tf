variable "admin_username" {
  type        = string
  description = "Administrator user name for virtual machine."
  default     = "my_admin"
}

variable "admin_password" {
  type        = string
  description = "Password must meet Azure complexity requirements."
  default     = "My.P@s$123-h3ll0"
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "The location where the resources are applied."
}

variable "sku" {
  type = map(any)
  default = {
    westeurope  = "16.04-LTS"
    northeurope = "18.04-LTS"
  }
}

variable "vm_size" {
  type = map(any)
  default = {
    small  = "Standard_DS1_v2"
    medium = "Standard_DS2_v2"
    large  = "Standard_DS3_v2"
  }
}

variable "size" {
  type        = string
  description = "Please pick a size: small, medium or large."
  default     = "medium"
}
