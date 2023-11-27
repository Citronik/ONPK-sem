data "openstack_compute_flavor_v2" "flavor" {
  name = var.flavor
}

data "openstack_images_image_v2" "image" {
  name = var.image
}

# data "openstack_compute_keypair_v2" "keypair" {
#   name = var.instance-kp
# }

# data "security_groups" "sec_groups" {
#   name = var.security_groups
# }

data "openstack_networking_network_v2" "network" {
  name = var.network_name
}