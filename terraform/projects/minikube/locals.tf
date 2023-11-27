locals {
  kis_os_url         = "https://158.193.152.44"
  kis_os_auth_url    = "${local.kis_os_url}:5000/v3/"
  kis_os_region      = "RegionOne"
  kis_os_domain_name = "admin_domain"

  kis_os_endpoint_override = {
    compute = "${local.kis_os_url}:8774/v2.1/",
    image   = "${local.kis_os_url}:9292/v2.0/",
    network = "${local.kis_os_url}:9696/v2.0/"
  }
  kis = {

    network = {
      cidr = "158.193.0.0/16"
    },
    instance = {
      flavor_name      = "2c2r20d",
      flavor_mini_name = "1c05r8d",
      image = {
        ubuntu = {
          name     = "ubuntu-22.04-KIS",
          username = "ubuntu"
        },
        debian = {
          name     = "debian-12-kis",
          username = "debian"
        }
      }
    }
  }
}