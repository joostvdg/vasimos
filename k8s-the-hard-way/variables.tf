variable "region" {
  default = "europe-west4"
}

variable "region_default_zone_base" {
  default = "europe-west4"
}

variable "region_default_zone" {
  default = "europe-west4-c"
}

variable "project_name" {
  description = "The ID of the Google Cloud project"
  default     = "cje2-208313"
}

variable "credentials_file_path" {
  description = "Path to the JSON file used to describe your account credentials"
  default     = "cje2-208313-1d119b193c74.json"
}

variable "gce_ssh_user" {
  description = "Username for the SSH connection"
  default     = "joostvdg"
}

variable "public_key_path" {
  description = "Path to file containing public key"
  default     = "~/.ssh/gcloud_id_rsa.pub"
}

variable "num_controllers" {
  description = "The number of controller VMs"
  default     = 3
}

variable "machine_type_controllers" {
  description = "The type of VM for machine_type_controllers"
  default     = "n1-standard-1"
}

variable "num_workers" {
  description = "The number of worker VMs"
  default     = 3
}

variable "machine_type_workers" {
  description = "The type of VM for workers"
  default     = "n1-standard-1"
}

variable "subnet_name" {
  description = "The name for the subnet"
  default     = "kubernetes"
}

variable "subnet_cidr" {
  default     = "10.240.0.0/24"
  description = "The cidr block for the subnet"
}

variable "kubernetes-cluster-dns" {
  default     = "kubernetes.default.svc.cluster.local"
  description = "DNS for the cluster, for host related queries such as health checks."
}
