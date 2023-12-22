# --- main.tf ---

# ----------------- user_data -----------------
data "cloudinit_config" "user_data_private" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    filename     = "userdata_minikube"
    content      = templatefile("/scripts/private_instance.sh", { K8S_VERSION = var.k8s_version })
  }
}

data "cloudinit_config" "user_data_jump" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    filename     = "userdata_update"
    content      = file("/scripts/updating.sh")
  }
}

# ----------------- instances keypairs -----------------
resource "openstack_compute_keypair_v2" "private_kp" {
  name       = "${var.project}-${var.environment}-private_kp"
  public_key = var.private_instance_key-pub
}

resource "openstack_compute_keypair_v2" "public_kp" {
  name       = "${var.project}-${var.environment}-public_kp"
  public_key = var.public_instance_key-pub
}

# --------------------- network ----------------------

module "network" {
  source              = "../../modules/network"
  name                = "${var.project}-${var.environment}"
  private_cidr        = var.private_cidr
  public_network_name = var.public_network_name
}

# ------------------ security_group --------------------

module "security_group_public" {
  source              = "../../modules/sec_group"
  security_group_name = "${var.project}-${var.environment}-public"
  rules               = var.public_rules
}

module "security_group_private" {
  source              = "../../modules/sec_group"
  security_group_name = "${var.project}-${var.environment}-private"
  rules               = var.private_rules
}

# --------------------- instances ----------------------
module "instance_jump" {
  depends_on    = [data.cloudinit_config.user_data_jump, module.security_group_public, module.network]
  source        = "../../modules/compute"
  instance_name = "${var.project}-${var.environment}-jump"
  instance-kp   = openstack_compute_keypair_v2.public_kp.name
  user_data     = data.cloudinit_config.user_data_jump.rendered
  image         = local.kis.instance.image.ubuntu.name
  #  image           = local.kis.instance.image.debian.name
  flavor          = local.kis.instance.flavor_name
  network_name    = module.network.network_name
  security_groups = [module.security_group_public.security_group_name]
  floating_ip_network = var.public_network_name
}

module "instance_private" {
  depends_on    = [data.cloudinit_config.user_data_private, module.security_group_private, module.network]
  source        = "../../modules/compute"
  instance_name = "${var.project}-${var.environment}-private"
  instance-kp   = openstack_compute_keypair_v2.private_kp.name
  user_data     = data.cloudinit_config.user_data_private.rendered
  image         = local.kis.instance.image.ubuntu.name
  #  image           = local.kis.instance.image.debian.name
  flavor          = local.kis.instance.flavor_name
  network_name    = module.network.network_name
  security_groups = [module.security_group_private.security_group_name]
  floating_ip_network = ""
}

resource "null_resource" "wait_for_jump" {
  depends_on = [ module.instance_jump ]

  connection {
    type        = "ssh"
    host        = module.instance_jump.instance_ip
    user        = local.kis.instance.image.ubuntu.username
    private_key = file("${var.project}-${var.environment}-public_kp.pem")
  }

  provisioner "remote-exec" {
    # Waiting for cloud-init to create files, cloud-init should create boot-finish file but couldnt test it as the OpenStack cannot create instances
    inline = [
      "until [ -f /tmp/.cloud-init-finished ]; do sleep 5; done",
      "iptables -t nat -A PREROUTING -i ens3 -p tcp --dport 8022 -j DNAT --to-destination ${module.instance_private.instance_ip}:22",
      "iptables -t nat -A POSTROUTING -j MASQUERADE"
    ]
  }
}


resource "null_resource" "wait_for_minikube" {
  triggers = {
    public_instance_ip  = module.instance_jump.instance_ip
    private_instance_ip = module.instance_private.instance_ip
  }
  connection {
    type = "ssh"
    host = module.instance_jump.instance_ip
    user = local.kis.instance.image.ubuntu.username
    private_key = file("${var.project}-${var.environment}-private_kp.pem")
    port = 8022
  }
  provisioner "remote-exec" {
    # Waiting for cloud-init to create files, cloud-init should create boot-finish file but couldnt test it as the OpenStack cannot create instances
    inline = [ 
      "until [ -f /tmp/.cloud-init-finished ]; do sleep 5; done",
      "sudo service iptables restart" 
    ]
  }
}