terraform {
  required_version = "~> 0.12"
}

# https://www.terraform.io/docs/providers/google/index.html
provider "google" {
  version   = "~> 2.18.1"
  project   = "${var.project}"
  region    = "europe-west4"
  zone      = "europe-west4-b"
}

resource "google_container_cluster" "primary" {
  name        = "${var.name}"
  location    = "${var.location}"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool  = true
  initial_node_count        = 1
  min_master_version        = "${var.cluster_master_version}"
  resource_labels           = {
    environment = "development"
    created-by  = "terraform"
    owner       = "joostvdg"
  }

  # Configuration options for the NetworkPolicy feature.
  network_policy {
    # Whether network policy is enabled on the cluster. Defaults to false.
    # In GKE this also enables the ip masquerade agent
    # https://cloud.google.com/kubernetes-engine/docs/how-to/ip-masquerade-agent
    enabled = true

    # The selected network policy provider. Defaults to PROVIDER_UNSPECIFIED.
    provider = "CALICO"
  }

}

resource "google_container_node_pool" "nodepool1" {
  name       = "pool1"
  location   =  "${var.location}"
  cluster    =  "${google_container_cluster.primary.name}"
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 4
  }

  node_config {
    machine_type = "n1-standard-2"
  }
}

resource "google_container_node_pool" "nodepool2" {
  name       = "pool2"
  location   = "europe-west4"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 3
  }

  node_config {
    machine_type = "n2-standard-2"
  }
}