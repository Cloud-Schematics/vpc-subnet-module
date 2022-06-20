##############################################################################
# Account Variables
##############################################################################

variable "prefix" {
  description = "The prefix that you would like to append to your resources"
  type        = string
}

variable "region" {
  description = "The region to which to deploy the VPC"
  type        = string
}

variable "resource_group_id" {
  description = "ID of the resource group where subnets will be provisioned"
  type        = string
  default     = null
}

variable "tags" {
  description = "List of Tags for the resource created"
  type        = list(string)
  default     = null
}

##############################################################################

##############################################################################
# VPC Variables
##############################################################################

variable "vpc_id" {
  description = "ID of the VPC where subnets will be created"
  type        = string
}

variable "use_manual_address_prefixes" {
  description = "True if using manual address prefix creation. If false, address prefixes will be created in the VPC automatically"
  type        = bool
  default     = false
}

variable prepend_prefix_to_network_acl_names {
  description = "Add the prefix to network acl names when looking them up from `network_acls` variable."
  type        = bool
  default     = true
}

variable "network_acls" {
  description = "List of ACLs to be used for subnets."
  type = list(
    object({
      id   = string
      name = string
    })
  )
  default = []
}

variable "public_gateways" {
  description = "Map of public gatways"
  type = object({
    zone-1 = string
    zone-2 = string
    zone-3 = string
  })
  default = {
    zone-1 = null
    zone-2 = null
    zone-3 = null
  }
}

##############################################################################

##############################################################################
# Subnets
##############################################################################

variable "subnets" {
  description = "List of subnets for the vpc. For each item in each array, a subnet will be created. Items can be either CIDR blocks or total ipv4 addressess. Public gateways will be enabled only in zones where a gateway has been created"
  type = object({
    zone-1 = list(object({
      name           = string
      cidr           = string
      public_gateway = optional(bool)
      acl_name       = string
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

  default = {
    zone-1 = [
      {
        name           = "subnet-a"
        cidr           = "10.10.10.0/24"
        public_gateway = true
        acl_name       = "vpc-acl"
      }
    ],
    zone-2 = [
      {
        name           = "subnet-b"
        cidr           = "10.20.10.0/24"
        public_gateway = true
        acl_name       = "vpc-acl"
      }
    ],
    zone-3 = [
      {
        name           = "subnet-c"
        cidr           = "10.30.10.0/24"
        public_gateway = false
        acl_name       = "vpc-acl"
      }
    ]
  }

  validation {
    error_message = "Keys for `subnets` must be in the order `zone-1`, `zone-2`, `zone-3`."
    condition     = keys(var.subnets)[0] == "zone-1" && keys(var.subnets)[1] == "zone-2" && keys(var.subnets)[2] == "zone-3"
  }

}

##############################################################################