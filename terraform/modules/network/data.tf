data "openstack_networking_network_v2" "public_network" {
  name = var.public_network_name
}