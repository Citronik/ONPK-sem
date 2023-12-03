# modules/sec_group/main.tf

resource "openstack_networking_secgroup_v2" "sec_group" {
  name        = "${var.security_group_name}-sg"
  description = "${var.security_group_name} Security Group"

  # dynamic "rule" {
  #   for_each = var.rules
  #   content {
  #     direction   = "ingress"
  #     ip_protocol = rule.value.protocol
  #     from_port   = rule.value.from_port
  #     to_port     = rule.value.to_port
  #     cidr        = rule.value.cidr_blocks
  #   }
  # }
}

resource "openstack_networking_secgroup_rule_v2" "rule" {
  count = length(var.rules)

  direction         = "ingress"
  protocol          = var.rules[count.index].protocol
  port_range_min    = var.rules[count.index].from_port
  port_range_max    = var.rules[count.index].to_port
  ethertype         = "IPv4"
  remote_ip_prefix  = var.rules[count.index].cidr_blocks
  security_group_id = openstack_networking_secgroup_v2.sec_group.id
  
}