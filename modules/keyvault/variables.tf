variable "resource_group_name" {
  description = "Resource group for Key Vault"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "northeurope"
}

variable "tenant_id" {
  description = "Entra ID tenant ID"
  type        = string
}

variable "admin_object_id" {
  description = "Object ID of admin user or group for Key Vault access"
  type        = string
}

variable "spoke_name" {
  description = "Name of the spoke this Key Vault belongs to"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for audit logging"
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}