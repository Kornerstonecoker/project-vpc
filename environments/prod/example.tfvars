# Copy to terraform.tfvars and fill in your values
location    = "northeurope"
environment = "dev"

vnet_cidr        = "10.x.0.0/16"
app_subnet_cidr  = "10.x.1.0/24"
data_subnet_cidr = "10.x.2.0/24"

hub_vnet_id             = "/subscriptions/xxx/resourceGroups/rg-connectivity-hub/..."
hub_vnet_name           = "vnet-hub"
hub_resource_group_name = "rg-connectivity-hub"
route_table_id          = "/subscriptions/xxx/resourceGroups/rg-connectivity-hub/..."

log_analytics_workspace_id = "/subscriptions/xxx/resourceGroups/rg-security-defender/..."

tenant_id       = "your-tenant-id"
admin_object_id = "your-object-id"

tags = {
  environment = "dev"
  project     = "project-vpc"
  managed_by  = "terraform"
  owner       = "your-name"
}