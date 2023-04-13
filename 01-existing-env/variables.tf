

variable "vnet_resource_group" {
  type        = string
  description = "RG name in Azure"
  default     = "rg-azure-demo-lab"
}

variable "location" {
  type        = string
  description = "RG location in Azure"
  default     = "westeurope"
}

variable "vnet_name" {
  type        = string
  description = "VNET name in Azure"
  default     = "vnet-azure-demo-lab"
}