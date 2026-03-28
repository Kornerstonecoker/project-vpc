variable "root_management_group_id" {
  description = "The tenant root management group ID"
  type        = string
}

variable "prefix" {
  description = "Prefix applied to all management group names"
  type        = string
  default     = "mg"
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}