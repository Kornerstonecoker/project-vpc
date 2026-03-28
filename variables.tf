variable "location" {
  description = "Primary Azure region"
  type        = string
  default     = "northeurope"
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    project    = "project-vpc"
    managed_by = "terraform"
    owner      = "kornerstonecoker"
  }
}