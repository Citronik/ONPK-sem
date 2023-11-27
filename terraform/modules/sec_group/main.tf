# modules/sec_group/main.tf

resource "openstack_networking_secgroup_v2" "sec_group" {
  name        = "${var.security_group_name}-sg"
  description = "${var.security_group_name} Security Group"

  dynamic "rule" {
    for_each = var.rules
    content {
      direction     = "ingress"
      ip_protocol      = rule.value.protocol
      from_port = rule.value.from_port
      to_port = rule.value.to_port
      cidr = rule.value.cidr_blocks
    }
  }
}