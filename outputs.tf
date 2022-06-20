##############################################################################
# Subnet Outputs
##############################################################################

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


##############################################################################