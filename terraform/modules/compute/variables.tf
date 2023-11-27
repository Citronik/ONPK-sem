# --- variables.tf ---

variable "network_name" {
  type = string
}

variable "instance-kp" {
  type = string
}

variable "user_data" {
  type = string
}

variable "image" {
  type = string
}

variable "flavor" {
  type = string
}

variable "instance_name" {
  type    = string
  default = "instance"
}

variable "security_groups" {
  type    = list(string)
  default = ["default"]
}