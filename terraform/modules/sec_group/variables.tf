# --- variables.tf ---

variable "security_group_name" {
  description = "Name of the security group"
}

variable "rules" {
  description = "List of security group rules"
  type = list(object({
    protocol    = string
    from_port   = number
    to_port     = number
    cidr_blocks = string
  }))
}