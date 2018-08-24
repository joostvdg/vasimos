resource "google_compute_firewall" "khw-allow-internal" {
  name    = "kubernetes-the-hard-way-allow-internal"
  network = "${google_compute_network.khw.name}"

  source_ranges = ["10.240.0.0/24", "10.200.0.0/16", "10.32.0.0/24"]

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }
}

# gcloud compute firewall-rules create kubernetes-allow-dns \
#    --allow tcp:53,udp:53 \
#    --network kubernetes \
#    --source-ranges 0.0.0.0/0

resource "google_compute_firewall" "khw-allow-dns" {
  name    = "kubernetes-the-hard-way-allow-dns"
  network = "${google_compute_network.khw.name}"

  source_ranges = ["0.0.0.0"]

  allow {
    protocol = "tcp"
    ports    = ["53", "443"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }
}

resource "google_compute_firewall" "khw-allow-health-check" {
  name    = "kubernetes-the-hard-way-allow-health-check"
  network = "${google_compute_network.khw.name}"

  allow {
    protocol = "tcp"
  }

  source_ranges = ["209.85.152.0/22", "209.85.204.0/22", "35.191.0.0/16"]
}

resource "google_compute_firewall" "khw-allow-external" {
  name    = "kubernetes-the-hard-way-allow-external"
  network = "${google_compute_network.khw.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "6443"]
  }

  source_ranges = ["0.0.0.0/0"]
}
