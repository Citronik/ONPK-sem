# --- computing/providers.tf ---

# https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs
terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.52.1"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  user_name          = var.username
  tenant_name        = var.tenant_name
  password           = var.password
  auth_url           = local.kis_os_auth_url
  region             = local.kis_os_region
  insecure           = true
  domain_name        = local.kis_os_domain_name
  endpoint_overrides = local.kis_os_endpoint_override
}
