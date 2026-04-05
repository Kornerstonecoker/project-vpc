variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vnet_cidr" {
  description = "CIDR block for spoke VNet"
  type        = string
}

variable "app_subnet_cidr" {
  description = "CIDR for app subnet"
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
  description = "Hub resource group name"
  type        = string
}

variable "route_table_id" {
  description = "Hub route table ID"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  type        = string
}

variable "tenant_id" {
  description = "Entra ID tenant ID"
  type        = string
}

variable "admin_object_id" {
  description = "Admin user object ID"
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
}