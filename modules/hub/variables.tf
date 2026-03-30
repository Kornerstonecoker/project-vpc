variable "resource_group_name" {
  description = "Resource group for hub networking resources"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "northeurope"
}

variable "hub_vnet_cidr" {
  description = "CIDR block for hub VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "gateway_subnet_cidr" {
  description = "CIDR for GatewaySubnet — must be named exactly this"
  type        = string
  default     = "10.0.0.0/27"
}

variable "firewall_subnet_cidr" {
  description = "CIDR for AzureFirewallSubnet — must be named exactly this, min /26"
  type        = string
  default     = "10.0.1.0/26"
}

variable "bastion_subnet_cidr" {
  description = "CIDR for AzureBastionSubnet — must be named exactly this"
  type        = string
  default     = "10.0.2.0/27"
}

variable "management_subnet_cidr" {
  description = "CIDR for management tools subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}