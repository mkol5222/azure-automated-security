

variable "resource_group_name" {
  type        = string
  description = "RG name in Azure"
  default     = "rg-azure-demo-lab"
}

variable "resource_group_location" {
  type        = string
  description = "RG location in Azure"
  default     = "westeurope"
}

variable "virtual_network_name" {
  type        = string
  description = "VNET name in Azure"
  default     = "vnet-azure-demo-lab"
}