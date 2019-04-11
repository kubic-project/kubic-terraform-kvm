variable "count_vms" {
  description = "number of virtual-machine of same type that will be created"
  default     = 3
}

variable "memory" {
  description = "The amount of RAM (MB) for a node"
  default     = 2048
}

variable "vcpu" {
  description = "The amount of virtual CPUs for a node"
  default     = 2
}
