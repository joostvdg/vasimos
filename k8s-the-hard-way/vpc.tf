resource "google_compute_network" "khw" {
  name                    = "kubernetes-the-hard-way"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "khw-kubernetes" {
  name          = "${var.subnet_name}"
  ip_cidr_range = "${var.subnet_cidr}"
  region        = "${var.region}"
  network       = "${google_compute_network.khw.self_link}"
}
