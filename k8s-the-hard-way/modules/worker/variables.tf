variable "num" {
  description = "The number of controller VMs"
}

variable "machine_type" {
  description = "The type of VM for controllers"
}

variable "zone" {
  description = "The zone to create the controllers in"
}

variable "subnet" {
  description = "The subnet to create the nic in"
}
