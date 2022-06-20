##############################################################################
# Convert ACLs to Map for easy lookup
##############################################################################

module "acl_list_to_map" {
  source = "./list_to_map"
  list   = var.network_acls
}

##############################################################################

##############################################################################
# Convert Subnet Object into List
##############################################################################

locals {
  # Get used zones
  subnet_zones = [
    # return zone key if not null
    for zone in keys(var.subnets) :
    zone if var.subnets[zone] != null
  ]

  # Create prefix for ACLs
  acl_prefix = var.prepend_prefix_to_network_acl_names ? "${var.prefix}-" : ""

  # Create list of subnets
  subnet_list = flatten([
    # For each zone in the composed zones
    for zone in local.subnet_zones :
    [
      # For each subnet in that zone
      for subnet in var.subnets[zone] :
      # Add zone and count to subnet object
      merge(
        subnet,
        {
          zone        = replace(zone, "zone", var.region)
          network_acl = (
            # Lookup prefix plus acl_name id
            lookup(module.acl_list_to_map.value, "${local.acl_prefix}${subnet.acl_name}", null) == null 
            ? null 
            : module.acl_list_to_map.value["${local.acl_prefix}${subnet.acl_name}"].id
          )
          public_gateway = (
            subnet.public_gateway != true       # if not using gateway
            ? null                              # null
            : var.public_gateways[zone] == null # if trying to use gateway and no id
            ? null                              # null
            : var.public_gateways[zone]         # else lookup zone key
          )
        }
      )
    ]
  ])
}

##############################################################################