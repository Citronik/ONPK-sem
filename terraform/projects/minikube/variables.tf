# --- variables.tf ---

variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "tenant_name" {
  type = string
}

# Default: ext-net-154 (public network -> instance is connected to the public internet)
variable "public_network_name" {
  type    = string
  default = "ext-net-154"
}

variable "private_cidr" {
  type = string
}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "private_instance_key-pub" {
  type = string
}

variable "public_instance_key-pub" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "public_rules" {
  description = "List of security group rules"
  type = list(object({
    protocol    = string
    from_port   = number
    to_port     = number
    cidr_blocks = string
  }))
}

variable "private_rules" {
  description = "List of security group rules"
  type = list(object({
    protocol    = string
    from_port   = number
    to_port     = number
    cidr_blocks = string
  }))
}