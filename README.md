# VPC Subnet Module

Create any number of subnets across 1, 2, or 3 zones in a single VPC.

---

## Table of Contents

1. [Module Variables](#module-variables)
2. [Subnet Variable](#subnet-variable)
3. [Outputs](#outputs)
4. [Example Usage](#example-usage)

---

## Module Variables

Name                                | Type                                                        | Description                                                                                                       | Sensitive | Default
----------------------------------- | ----------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | --------- | ---------------------------------------------
prefix                              | string                                                      | The prefix that you would like to append to your resources                                                        |           | 
region                              | string                                                      | The region to which to deploy the VPC                                                                             |           | 
resource_group_id                   | string                                                      | ID of the resource group where subnets will be provisioned                                                        |           | null
tags                                | list(string)                                                | List of Tags for the resource created                                                                             |           | null
vpc_id                              | string                                                      | ID of the VPC where subnets will be created                                                                       |           | 
use_manual_address_prefixes         | bool                                                        | True if using manual address prefix creation. If false, address prefixes will be created in the VPC automatically |           | false
prepend_prefix_to_network_acl_names | bool                                                        | Add the prefix to network acl names when looking them up from `network_acls` variable.                            |           | true
network_acls                        | list( object({ id = string name = string }) )               | List of ACLs to be used for subnets.                                                                              |           | []
public_gateways                     | object({ zone-1 = string zone-2 = string zone-3 = string }) | Map of public gatways                                                                                             |           | { zone-1 = null zone-2 = null zone-3 = null }

---

## Subnet Variable

List of subnets for the vpc. For each item in each array, a subnet will be created. Items can be either CIDR blocks or total ipv4 addressess. Public Gateways will be enabled only in zones where a gateway has been created.

```terraform
  type = object({
    zone-1 = list(object({
      name           = string         # Name of the subnet
      cidr           = string         # CIDR block
      public_gateway = optional(bool) # Use public gateway
      acl_name       = string         # Name of network ACL to use. Will only be attached if name is found in var.network_acls
    }))
    zone-2 = list(object({
      name           = string
      cidr           = string
      public_gateway = optional(bool)
      acl_name       = string
    }))
    zone-3 = list(object({
      name           = string
      cidr           = string
      public_gateway = optional(bool)
      acl_name       = string
    }))
  })
```

---

## Outputs

- `subnet_zone_list`
```terraform
output "subnet_zone_list" {
  description = "A list containing subnet IDs and subnet zones"
  value = [
    for subnet in ibm_is_subnet.subnet : {
      name = subnet.name
      id   = subnet.id
      zone = subnet.zone
      cidr = subnet.ipv4_cidr_block
    }
  ]
}
```

---

## Example Usage

```terraform
module "subnets" {
  source                      = "github.com/Cloud-Schematics/vpc-subnet-module"
  prefix                      = var.prefix
  region                      = var.region
  tags                        = var.tags
  resource_group_id           = data.ibm_resource_group.resource_group.id
  vpc_id                      = ibm_is_vpc.vpc.id
  use_manual_address_prefixes = var.use_manual_address_prefixes
  network_acls                = module.network_acls.acls
  public_gateways             = module.public_gateways.gateways
  subnets                     = var.subnets
  depends_on                  = [module.address_prefixes] # Force dependecy on address prefixes to prevent creation errors
}
```