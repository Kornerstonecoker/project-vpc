variable "location" {
  description = "Azure region"
  type        = string
  default     = "northeurope"
}

variable "security_contact_email" {
  description = "Email address for Defender security alerts"
  type        = string
}
# Not using this variable for now, but leaving in place for future use when we enable paid Defender plans that require a phone number
# variable "security_contact_phone" {
#   description = "Phone number for security contact"
#   type        = string
#   default     = ""
# }

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for Defender data"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}