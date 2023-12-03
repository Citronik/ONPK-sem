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
}

resource "openstack_networking_floatingip_v2" "fip_1" {
  pool = var.public_network_name
}

resource "openstack_compute_floatingip_associate_v2" "fip_1" {
  floating_ip = openstack_networking_floatingip_v2.fip_1.address
  instance_id = module.instance_jump.instance_id
}

resource "null_resource" "wait_for_minikube" {
  triggers = {
    public_instance_ip  = module.instance_jump.instance_ip
    private_instance_ip = module.instance_private.instance_ip
  }

  provisioner "local-exec" {
    command = <<EOF
      set SSH_KEY_JUMP="${path.module}/${openstack_compute_keypair_v2.public_kp.name}.pem"
      set SSH_KEY_PRIVATE="${path.module}/${openstack_compute_keypair_v2.private_kp.name}.pem"

      set PUBLIC_INSTANCE_IP="${module.instance_jump.instance_ip}"
      set PRIVATE_INSTANCE_IP="${module.instance_private.instance_ip}"

      set USERNAME="${local.kis.instance.image.ubuntu.username}"

      ssh -i "%SSH_KEY_JUMP%" -N -L 8080:%PRIVATE_INSTANCE_IP%:22 -p 22 %USERNAME%@%PUBLIC_INSTANCE_IP%

      until ssh -i "%SSH_KEY_PRIVATE%" -p 8080 localhost "minikube profile list > /dev/null"; do
        echo "Waiting for minikube installation to complete..."
        sleep 5
      done
    EOF
  }
}