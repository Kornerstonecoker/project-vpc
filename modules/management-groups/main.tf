# -----------------------------------------------
# PLATFORM
# -----------------------------------------------
resource "azurerm_management_group" "platform" {
  name                       = "${var.prefix}-platform"
  display_name               = "Platform"
  parent_management_group_id = var.root_management_group_id
}

resource "azurerm_management_group" "connectivity" {
  name                       = "${var.prefix}-connectivity"
  display_name               = "Connectivity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "identity" {
  name                       = "${var.prefix}-identity"
  display_name               = "Identity"
  parent_management_group_id = azurerm_management_group.platform.id
}

resource "azurerm_management_group" "management" {
  name                       = "${var.prefix}-management"
  display_name               = "Management"
  parent_management_group_id = azurerm_management_group.platform.id
}

# -----------------------------------------------
# SECURITY
# -----------------------------------------------
resource "azurerm_management_group" "security" {
  name                       = "${var.prefix}-security"
  display_name               = "Security"
  parent_management_group_id = var.root_management_group_id
}

# -----------------------------------------------
# LANDING ZONES
# -----------------------------------------------
resource "azurerm_management_group" "landingzones" {
  name                       = "${var.prefix}-landingzones"
  display_name               = "Landing Zones"
  parent_management_group_id = var.root_management_group_id
}

resource "azurerm_management_group" "corp" {
  name                       = "${var.prefix}-corp"
  display_name               = "Corp"
  parent_management_group_id = azurerm_management_group.landingzones.id
}

resource "azurerm_management_group" "online" {
  name                       = "${var.prefix}-online"
  display_name               = "Online"
  parent_management_group_id = azurerm_management_group.landingzones.id
}

# -----------------------------------------------
# SANDBOX
# -----------------------------------------------
resource "azurerm_management_group" "sandbox" {
  name                       = "${var.prefix}-sandbox"
  display_name               = "Sandbox"
  parent_management_group_id = var.root_management_group_id
}

# -----------------------------------------------
# DECOMMISSIONED
# -----------------------------------------------
resource "azurerm_management_group" "decommissioned" {
  name                       = "${var.prefix}-decommissioned"
  display_name               = "Decommissioned"
  parent_management_group_id = var.root_management_group_id
}

# -----------------------------------------------
# AZURE POLICY — Require tags on all resources
# Assigned at mg-platform — inherits to all children
# -----------------------------------------------
resource "azurerm_management_group_policy_assignment" "require_tags" {
  name                 = "require-resource-tags"
  display_name         = "Require mandatory resource tags"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025"
  management_group_id  = azurerm_management_group.platform.id

  parameters = jsonencode({
    tagName = {
      value = "managed_by"
    }
  })
}

# -----------------------------------------------
# AZURE POLICY — Deny public IP on VMs
# Assigned at mg-landingzones
# -----------------------------------------------
resource "azurerm_management_group_policy_assignment" "deny_public_ip" {
  name                 = "deny-public-ip-vm"
  display_name         = "Deny public IP addresses on VMs"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/83a86a26-fd1f-447c-b59d-e51f44264114"
  management_group_id  = azurerm_management_group.landingzones.id
  enforce              = false
}

# -----------------------------------------------
# AZURE POLICY — Allowed locations
# Assigned at mg-platform
# -----------------------------------------------
resource "azurerm_management_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  display_name         = "Restrict resources to approved regions"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  management_group_id  = azurerm_management_group.platform.id

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = ["northeurope", "westeurope"]
    }
  })
}

# -----------------------------------------------
# AZURE POLICY — Enable Defender for Cloud
# Assigned at mg-security
# -----------------------------------------------
resource "azurerm_management_group_policy_assignment" "enable_defender" {
  name                 = "enable-defender-cloud"
  display_name         = "Enable Microsoft Defender for Cloud"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"
  management_group_id  = azurerm_management_group.security.id
  enforce              = false
}