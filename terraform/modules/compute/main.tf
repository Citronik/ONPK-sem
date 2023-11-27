resource "openstack_compute_instance_v2" "private_instance" {
  #depends_on      = [openstack_networking_secgroup_v2.sec_group_onpk_private, openstack_compute_instance_v2.jump_instance]
  name            = var.instance_name
  image_id        = data.openstack_images_image_v2.image.id
  flavor_id       = data.openstack_compute_flavor_v2.flavor.id
  key_pair        = var.instance-kp
  security_groups = var.security_groups

  user_data = var.user_data

  network {
    name = data.openstack_networking_network_v2.network.name
  }
}