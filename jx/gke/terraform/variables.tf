variable "project" { }

variable "name" {
  description = "The name of the cluster (required)"
  default     = "joostvdg-prep"
}

variable "description" {
  description = "The description of the cluster"
  default     = "Prep environment for Joost"
}

variable "location" {
  description = "The location to host the cluster"
  default     = "europe-west4"
}

variable "cluster_master_version" {
  description = "The minimum kubernetes version for the master nodes"
  default     = "1.14.7-gke.10"
}
