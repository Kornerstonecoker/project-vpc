variable "spoke_name" {
  description = "Name of the spoke e.g. dev, staging, prod"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for spoke networking resources"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "northeurope"
}

variable "vnet_cidr" {
  description = "CIDR block for spoke VNet"
  type        = string
}

variable "app_subnet_cidr" {
  description = "CIDR for application subnet"
  type        = string
}

variable "data_subnet_cidr" {
  description = "CIDR for data subnet"
  type        = string
}

variable "hub_vnet_id" {
  description = "Hub VNet ID for peering"
  type        = string
}

variable "hub_vnet_name" {
  description = "Hub VNet name for peering"
  type        = string
}

variable "hub_resource_group_name" {
  description = "Hub resource group name for peering"
  type        = string
}

variable "route_table_id" {
  description = "Hub route table ID for UDR association"
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}