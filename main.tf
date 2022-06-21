##############################################################################
# Subnet List to Map
##############################################################################

module "subnet_list_to_map" {
  source = "./list_to_map"
  list   = local.subnet_list
  prefix = var.prefix
}

##############################################################################

##############################################################################
# Create Subnet Prefixes
##############################################################################

resource "ibm_is_vpc_address_prefix" "subnet_prefix" {
  for_each = var.use_manual_address_prefixes ? {} : module.subnet_list_to_map.value
  name     = "${var.prefix}-${each.value.name}"
  zone     = each.value.zone
  vpc      = var.vpc_id
  cidr     = each.value.cidr
}

##############################################################################

##############################################################################
# Create Subnets
##############################################################################

resource "ibm_is_subnet" "subnet" {
  for_each        = module.subnet_list_to_map.value
  vpc             = var.vpc_id
  resource_group  = var.resource_group_id
  tags            = var.tags
  name            = each.key
  zone            = each.value.zone
  ipv4_cidr_block = var.use_manual_address_prefixes ? each.value.cidr : ibm_is_vpc_address_prefix.subnet_prefix[each.key].cidr
  network_acl     = each.value.network_acl
  public_gateway  = each.value.public_gateway
}

##############################################################################