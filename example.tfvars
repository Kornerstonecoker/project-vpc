# Copy this file to terraform.tfvars and fill in your values
# Do NOT commit terraform.tfvars — it is gitignored

location            = "northeurope"
resource_group_name = "rg-hub-spoke"
tags = {
  project    = "project-vpc"
  managed_by = "terraform"
  owner      = "your-name"
}