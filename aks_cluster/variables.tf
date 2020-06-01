variable "resource_group_name" {
  type = string
}

variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "outbound_type" {
  type = string
  default = "loadBalancer"
}

variable "private_cluster_enabled" {
  type = bool
  default = false
}

variable "create_cluster" {
  type = bool
  default = true
}